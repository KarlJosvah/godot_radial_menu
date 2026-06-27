@tool
extends "res://core/config.gd"

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
