@tool
extends "res://core/render.gd"

# ====================================================================================================

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
