@tool
extends Node

var wheel: Control

func _ready() -> void:
	if not wheel:
		wheel = get_parent()

func init(wheel_node: Control) -> void:
	wheel = wheel_node

func draw_wheel() -> void:
	if not wheel:
		return
	var nb_options = len(wheel.options) - 1;
	var offset = - wheel.sprite_size * wheel.sprite_offset_percent / 100.0;
	
	wheel.draw_circle(Vector2.ZERO, wheel.outer_radius, wheel.bg_color, true, -1, true);
	wheel.draw_circle(Vector2.ZERO, wheel.inner_radius, wheel.line_color, false, wheel.line_width, true);
	
	_draw_line(nb_options);
	_draw_selected(nb_options);
	_draw_items(nb_options, offset);

func _draw_line(nb_options: int) -> void:
	for i in range(nb_options):
		var rads = (TAU * i) / (nb_options) + wheel.ANGLE_OFFSET;
		var point = Vector2.from_angle(rads);
		var from = point * wheel.inner_radius;
		var to = point * wheel.outer_radius;
		wheel.draw_line(from, to, wheel.line_color, wheel.line_width, true);

func _draw_selected(nb_options : int) -> void:
	if wheel.selected_options_index == 0:
		return;
	if nb_options <= 0:
		return;
	
	var start_rads = (TAU * (wheel.selected_options_index - 1)) / nb_options + wheel.ANGLE_OFFSET;
	var end_rads = (TAU * wheel.selected_options_index) / nb_options + wheel.ANGLE_OFFSET;
	
	var center = Vector2.ZERO;
	var radius = (wheel.inner_radius + wheel.outer_radius + wheel.line_width) / 2.0;
	var width = wheel.outer_radius - wheel.inner_radius - (wheel.line_width / 2.0);
	
	wheel.draw_arc(center, radius, start_rads, end_rads, 64, wheel.highlight_color, width, true);

func _draw_items(nb_options: int, offset: Vector2) -> void:
	if wheel.options.is_empty():
		return;
		
	if wheel.options[0] and wheel.options[0].atlas:
		var region = wheel.options[0].region;
		if region.size == Vector2.ZERO:
			region = Rect2(Vector2.ZERO, wheel.options[0].atlas.get_size());
		wheel.draw_texture_rect_region(
			wheel.options[0].atlas,
			Rect2(offset, wheel.sprite_size),
			region
		);
	
	for i in range(1, len(wheel.options)):
		if not wheel.options[i] or not wheel.options[i].atlas:
			continue;
		var start_rads = (TAU * (i - 1)) / nb_options + wheel.ANGLE_OFFSET;
		var end_rads = (TAU * i) / nb_options + wheel.ANGLE_OFFSET;
		var mid_rads = (start_rads + end_rads) / 2.0;
		var mid_radius = (wheel.inner_radius + wheel.outer_radius) / 2;
		
		var draw_pos = mid_radius * Vector2.from_angle(mid_rads) + offset;
		var region = wheel.options[i].region;
		if region.size == Vector2.ZERO:
			region = Rect2(Vector2.ZERO, wheel.options[i].atlas.get_size());
		wheel.draw_texture_rect_region(
			wheel.options[i].atlas,
			Rect2(draw_pos, wheel.sprite_size),
			region
		)
