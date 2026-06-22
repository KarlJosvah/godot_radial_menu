@tool
extends Control;

signal on_wheel_opened();
signal on_wheel_closed(selected_index: int);
signal on_selection_change(selected_index: int);

# ====================================================================================================

@export_group("Items")
@export var options: Array[WheelOption]:
	set(value):
		options = value;
		if is_node_ready():
			queue_redraw();

@export_subgroup("config")
@export_range(10.0, 100.0) var sprite_thickness_percent: float = 80.0:
	set(value):
		sprite_thickness_percent = value
		if is_node_ready():
			_update_radius();
			queue_redraw();

## WARNING : This variable is currently non-functional and will be fixed in a future update.
@export_range(10.0, 100.0) var sprite_offset_percent: float = 50.0:
	set(value):
		sprite_offset_percent = value
		if is_node_ready():
			_update_radius();
			queue_redraw();
		update_configuration_warnings();

# ====================================================================================================

@export_group("Layout")
@export var bg_color: Color = Color(0x327990b0):
	set(value):
		bg_color = value;
		if is_node_ready():
			queue_redraw();

@export var line_color: Color = Color.WHITE:
	set(value):
		line_color = value;
		if is_node_ready():
			queue_redraw();

@export var highlight_color: Color = Color.DIM_GRAY;

@export_range(20.0, 100.0) var outer_radius_percent: float = 75.0:
	set(value):
		outer_radius_percent = value;
		if is_node_ready():
			_update_radius();
			queue_redraw();

@export_range(10.0, 60.0) var inner_radius_percent: float = 50.0:
	set(value):
		inner_radius_percent = value;
		if is_node_ready():
			_update_radius();
			queue_redraw();

@export var line_width: int = 4:
	set(value):
		line_width = max(1, value);
		if is_node_ready():
			_update_radius();
			queue_redraw();

# ====================================================================================================

@export_group("")

enum Joy_Axis {
	ANY,
	LEFT,
	RIGHT
}

@export var joy_axe : Joy_Axis = Joy_Axis.ANY;

# ====================================================================================================

const animation_group: Array[String] = ["ease_in_speed", "ease_out_speed"];
@export var animation: bool = false:
	set(value):
		animation = value;
		notify_property_list_changed();
		if is_node_ready():
			queue_redraw();

@export var ease_in_speed: float = 0.25:
	set(value):
		ease_in_speed = max(0, value);
@export var ease_out_speed: float = 0.15:
	set(value):
		ease_out_speed = max(0, value);

# ====================================================================================================

var outer_radius: float = 0.0;
var inner_radius: float = 0.0;
var sprite_size: Vector2 = Vector2.ZERO;
var transition_tween: Tween;
const ANGLE_OFFSET = -PI / 2.0;

var is_opened : bool = false;
var selected_options_index : int = 0:
	set(value):
		if not is_opened:
			return;
		var target_value = value
		if target_value == 0 and using_joypad:
			if Time.get_ticks_msec() - last_joypad_push_time < 150:
				target_value = last_non_zero_selected_index;
				
		if selected_options_index != target_value:
			selected_options_index = target_value;
			queue_redraw();
			var selected_index : int = -1;
			if target_value < len(options):
				selected_index = target_value;
			on_selection_change.emit(selected_index);

# ====================================================================================================

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed);
	_update_radius();
	_init();
	queue_redraw();

func _init() -> void:
	scale = Vector2.ZERO;
	visible = false;
	if Engine.is_editor_hint():
		scale = Vector2.ONE;
		visible = true;

# ====================================================================================================

var virtual_mouse_pos: Vector2 = Vector2.ZERO;
var using_joypad: bool = false;
var last_joypad_push_time: int = 0;
var last_non_zero_selected_index: int = 0;
var previous_mouse_mode = Input.MOUSE_MODE_VISIBLE;

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return;
	if not visible:
		return;
	if event is InputEventMouseMotion:
		virtual_mouse_pos += event.relative;
		virtual_mouse_pos = virtual_mouse_pos.limit_length(outer_radius);
		using_joypad = false;

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return ;
	if not visible:
		return ;
	
	var joy_direction : Vector2;
	if joy_axe == Joy_Axis.ANY:
		var left_dir = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		);
		var right_dir = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		);
		if left_dir.length() > right_dir.length():
			joy_direction = left_dir;
		else:
			joy_direction = right_dir;
	elif joy_axe == Joy_Axis.LEFT:
		joy_direction = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		);
	elif joy_axe == Joy_Axis.RIGHT:
		joy_direction = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		);
	var joy_deadzone = 0.3;
	
	if joy_direction.length() > joy_deadzone:
		using_joypad = true;
		last_joypad_push_time = Time.get_ticks_msec();
		var nb_options = len(options) - 1;
		if nb_options > 0:
			var joy_rads = fposmod(joy_direction.angle() - ANGLE_OFFSET, TAU);
			selected_options_index = floor((joy_rads / TAU) * nb_options) + 1;
			if selected_options_index > 0:
				last_non_zero_selected_index = selected_options_index;
		else:
			selected_options_index = 0;
	elif using_joypad:
		selected_options_index = 0;
	else:
		var mouse_pos = virtual_mouse_pos if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else get_local_mouse_position();
		var mouse_radius = mouse_pos.length();
		
		if mouse_radius < inner_radius:
			selected_options_index = 0;
		else:
			var nb_options = len(options) - 1;
			if nb_options > 0:
				var mouse_rads = fposmod(mouse_pos.angle() - ANGLE_OFFSET, TAU);
				selected_options_index = floor((mouse_rads / TAU) * nb_options) + 1;
			else:
				selected_options_index = 0;

# ====================================================================================================

func _draw() -> void:
	var nb_options = len(options) - 1;
	var offset = - sprite_size * sprite_offset_percent / 100.0;
	
	draw_circle(Vector2.ZERO, outer_radius, bg_color, true, -1, true);
	draw_circle(Vector2.ZERO, inner_radius, line_color, false, line_width, true);
	
	_draw_line(nb_options);
	_draw_selected(nb_options);
	_draw_items(nb_options, offset);

func _draw_line(nb_options: int):
	for i in range(nb_options):
		var rads = (TAU * i) / (nb_options) + ANGLE_OFFSET;
		var point = Vector2.from_angle(rads);
		var from = point * inner_radius;
		var to = point * outer_radius;
		draw_line(from, to, line_color, line_width, true);

func _draw_selected(nb_options : int) -> void:
	if selected_options_index == 0:
		return;
	if nb_options <= 0:
		return;
	
	var start_rads = (TAU * (selected_options_index - 1)) / nb_options + ANGLE_OFFSET;
	var end_rads = (TAU * selected_options_index) / nb_options + ANGLE_OFFSET;
	
	var center = Vector2.ZERO;
	var radius = (inner_radius + outer_radius + line_width) / 2.0;
	var width = outer_radius - inner_radius - (line_width / 2.0);
	
	draw_arc(center, radius, start_rads, end_rads, 64, highlight_color, width, true);

func _draw_items(nb_options: int, offset: Vector2):
	if options.is_empty():
		return;
		
	if options[0] and options[0].atlas:
		draw_texture_rect_region(
			options[0].atlas,
			Rect2(offset, sprite_size),
			options[0].region
		);
	
	for i in range(1, len(options)):
		if not options[i] or not options[i].atlas:
			continue;
		var start_rads = (TAU * (i - 1)) / nb_options + ANGLE_OFFSET;
		var end_rads = (TAU * i) / nb_options + ANGLE_OFFSET;
		var mid_rads = (start_rads + end_rads) / 2.0;
		var mid_radius = (inner_radius + outer_radius) / 2;
		
		var draw_pos = mid_radius * Vector2.from_angle(mid_rads) + offset;
		draw_texture_rect_region(
			options[i].atlas,
			Rect2(draw_pos, sprite_size),
			options[i].region
		)

# ====================================================================================================

func open() -> void:
	is_opened = true;
	toggle_visibility();
	previous_mouse_mode = Input.mouse_mode;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	virtual_mouse_pos = Vector2.ZERO;
	using_joypad = false;
	last_joypad_push_time = 0;
	last_non_zero_selected_index = 0;
	on_wheel_opened.emit();

func close() -> int:
	is_opened = false;
	toggle_visibility();
	Input.mouse_mode = previous_mouse_mode;
	
	var selected_index : int = -1;
	if selected_options_index < len(options) and options[selected_options_index]:
		selected_index = selected_options_index;
	on_wheel_closed.emit(selected_index);
	return selected_index;

func toggle_visibility() -> void:
	if transition_tween and transition_tween.is_running():
		transition_tween.kill();
	
	var ease_in: float = ease_in_speed if animation else 0.0;
	var ease_out: float = ease_out_speed if animation else 0.0;
	if is_opened:
		self.show();
		transition_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
		transition_tween.tween_property(self , "scale", Vector2.ONE, ease_in);
	else:
		transition_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD);
		transition_tween.tween_property(self , "scale", Vector2.ZERO, ease_out);
		transition_tween.tween_callback(func(): visible = false);

# ====================================================================================================

func _on_viewport_size_changed() -> void:
	_update_radius();
	queue_redraw();

func _update_radius() -> void:
	var viewport_size: Vector2;
	
	if Engine.is_editor_hint():
		var width: float = ProjectSettings.get_setting("display/window/size/viewport_width");
		var height: float = ProjectSettings.get_setting("display/window/size/viewport_height");
		viewport_size = Vector2(width, height);
	else:
		viewport_size = get_viewport().get_visible_rect().size;
		
	var min_dimension: float = min(viewport_size.x, viewport_size.y);
	outer_radius = min_dimension * (outer_radius_percent / 100.0) / 2;
	inner_radius = outer_radius * (inner_radius_percent / 100);
	
	var ring_thickness: float = outer_radius - inner_radius;
	var available_space: float = ring_thickness - (line_width * 2);
	var bounded_size: float = available_space * (sprite_thickness_percent / 100.0);
	
	sprite_size = Vector2(bounded_size, bounded_size);

# ====================================================================================================

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [];
	if sprite_offset_percent != 50.0:
		warnings.append("The 'Sprite Offset Percent' variable is currently unstable and may not behave as expected.");
	return warnings;

func _validate_property(property: Dictionary) -> void:
	if property.name in animation_group:
		if not animation:
			property.usage = PROPERTY_USAGE_NO_EDITOR;
