@tool
extends Node

var wheel: Control

func _ready() -> void:
	if not wheel:
		wheel = get_parent()

func init(wheel_node: Control) -> void:
	wheel = wheel_node

func _on_viewport_size_changed() -> void:
	if wheel:
		_update_radius();
		wheel.queue_redraw();

func _update_radius() -> void:
	if not wheel:
		return
	var viewport_size: Vector2;
	
	if Engine.is_editor_hint():
		var width: float = ProjectSettings.get_setting("display/window/size/viewport_width");
		var height: float = ProjectSettings.get_setting("display/window/size/viewport_height");
		viewport_size = Vector2(width, height);
	else:
		viewport_size = wheel.get_viewport().get_visible_rect().size;
		
	var min_dimension: float = min(viewport_size.x, viewport_size.y);
	wheel.outer_radius = min_dimension * (wheel.outer_radius_percent / 100.0) / 2;
	wheel.inner_radius = wheel.outer_radius * (wheel.inner_radius_percent / 100);
	
	var ring_thickness: float = wheel.outer_radius - wheel.inner_radius;
	var available_space: float = ring_thickness - (wheel.line_width * 2);
	var bounded_size: float = available_space * (wheel.sprite_thickness_percent / 100.0);
	
	wheel.sprite_size = Vector2(bounded_size, bounded_size);

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [];
	if wheel and wheel.sprite_offset_percent != 50.0:
		warnings.append("The 'Sprite Offset Percent' variable is currently unstable and may not behave as expected.");
	return warnings;
