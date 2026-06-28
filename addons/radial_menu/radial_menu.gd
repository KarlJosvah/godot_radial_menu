@tool
extends Control
class_name RadialMenu;

@warning_ignore("unused_signal")
signal on_wheel_opened();
@warning_ignore("unused_signal")
signal on_wheel_closed(selected_index: int);
@warning_ignore("unused_signal")
signal on_selection_change(selected_index: int);

# ====================================================================================================

@export_group("Items")
@export var options: Array[RadialMenuOption]:
	set(value):
		options = value;
		linked_wheels.resize(options.size());
		notify_property_list_changed();
		if is_node_ready():
			queue_redraw();

# ====================================================================================================

const linked_wheels_group : Array[String] = ["linked_wheels"];
@export_subgroup("")
@export var linked_wheel : bool = false:
	set(value):
		linked_wheel = value;
		notify_property_list_changed();
		if is_node_ready():
			queue_redraw();

@export var linked_wheels : Array[RadialMenu]:
	set(value):
		if options:
			value.resize(options.size());
		linked_wheels = value;

# ====================================================================================================

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

func _ready() -> void:
	_ensure_child_nodes()
	$Input.init(self);
	$Render.init(self);
	$Interact.init(self);
	$Config.init(self);
	if has_node("Linked"):
		$Linked.init(self);
	get_viewport().size_changed.connect(_on_viewport_size_changed);
	_update_radius();
	_init();
	queue_redraw();

func _ensure_child_nodes() -> void:
	if not has_node("Input"):
		var n = Node.new()
		n.name = "Input"
		n.set_script(preload("res://addons/radial_menu/radial_menu_input.gd"))
		add_child(n)
	if not has_node("Render"):
		var n = Node.new()
		n.name = "Render"
		n.set_script(preload("res://addons/radial_menu/radial_menu_render.gd"))
		add_child(n)
	if not has_node("Interact"):
		var n = Node.new()
		n.name = "Interact"
		n.set_script(preload("res://addons/radial_menu/radial_menu_interact.gd"))
		add_child(n)
	if not has_node("Config"):
		var n = Node.new()
		n.name = "Config"
		n.set_script(preload("res://addons/radial_menu/radial_menu_config.gd"))
		add_child(n)
	if not has_node("Linked"):
		var n = Node.new()
		n.name = "Linked"
		n.set_script(preload("res://addons/radial_menu/radial_menu_linked.gd"))
		add_child(n)

func _init() -> void:
	scale = Vector2.ZERO;
	visible = false;
	if Engine.is_editor_hint():
		scale = Vector2.ONE;
		visible = true;

func _draw() -> void:
	if is_node_ready() and has_node("Render"):
		$Render.draw_wheel();

func open() -> void:
	if has_node("Interact"):
		$Interact.open();

func close() -> int:
	if has_node("Interact"):
		return $Interact.close();
	return -1;

func toggle_visibility() -> void:
	if has_node("Interact"):
		$Interact.toggle_visibility();

func _on_viewport_size_changed() -> void:
	if has_node("Config"):
		$Config._on_viewport_size_changed();

func _update_radius() -> void:
	if has_node("Config"):
		$Config._update_radius();

func _get_configuration_warnings() -> PackedStringArray:
	if has_node("Config"):
		return $Config._get_configuration_warnings();
	return PackedStringArray();

func _validate_property(property: Dictionary) -> void:
	if property.name in animation_group:
		if not animation:
			property.usage = PROPERTY_USAGE_NO_EDITOR;
	if property.name in linked_wheels_group:
		if not linked_wheel:
			property.usage = PROPERTY_USAGE_NO_EDITOR;
