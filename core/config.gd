@tool
extends Control

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
var virtual_mouse_pos: Vector2 = Vector2.ZERO;
var using_joypad: bool = false;
var last_joypad_push_time: int = 0;
var last_non_zero_selected_index: int = 0;
var previous_mouse_mode = Input.MOUSE_MODE_VISIBLE;

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

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [];
	if sprite_offset_percent != 50.0:
		warnings.append("The 'Sprite Offset Percent' variable is currently unstable and may not behave as expected.");
	return warnings;

func _validate_property(property: Dictionary) -> void:
	if property.name in animation_group:
		if not animation:
			property.usage = PROPERTY_USAGE_NO_EDITOR;
