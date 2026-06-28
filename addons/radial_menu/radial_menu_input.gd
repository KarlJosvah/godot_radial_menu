@tool
extends Node

var wheel: Control

func _ready() -> void:
	if not wheel:
		wheel = get_parent()

func init(wheel_node: Control) -> void:
	wheel = wheel_node

func _input(event: InputEvent) -> void:
	if not wheel or Engine.is_editor_hint():
		return;
	if not wheel.visible:
		return;
	if event is InputEventMouseMotion:
		wheel.virtual_mouse_pos += event.relative;
		wheel.virtual_mouse_pos = wheel.virtual_mouse_pos.limit_length(wheel.outer_radius);
		wheel.using_joypad = false;

func _process(_delta: float) -> void:
	if not wheel or Engine.is_editor_hint():
		return ;
	if not wheel.visible:
		return ;
	
	var joy_direction : Vector2;
	if wheel.joy_axe == wheel.Joy_Axis.ANY:
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
	elif wheel.joy_axe == wheel.Joy_Axis.LEFT:
		joy_direction = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		);
	elif wheel.joy_axe == wheel.Joy_Axis.RIGHT:
		joy_direction = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		);
	var joy_deadzone = 0.3;
	
	if joy_direction.length() > joy_deadzone:
		wheel.using_joypad = true;
		wheel.last_joypad_push_time = Time.get_ticks_msec();
		var nb_options = len(wheel.options) - 1;
		if nb_options > 0:
			var joy_rads = fposmod(joy_direction.angle() - wheel.ANGLE_OFFSET, TAU);
			wheel.selected_options_index = floor((joy_rads / TAU) * nb_options) + 1;
			if wheel.selected_options_index > 0:
				wheel.last_non_zero_selected_index = wheel.selected_options_index;
		else:
			wheel.selected_options_index = 0;
	elif wheel.using_joypad:
		wheel.selected_options_index = 0;
	else:
		var mouse_pos = wheel.virtual_mouse_pos if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else wheel.get_local_mouse_position();
		var mouse_radius = mouse_pos.length();
		
		if mouse_radius < wheel.inner_radius:
			wheel.selected_options_index = 0;
		else:
			var nb_options = len(wheel.options) - 1;
			if nb_options > 0:
				var mouse_rads = fposmod(mouse_pos.angle() - wheel.ANGLE_OFFSET, TAU);
				wheel.selected_options_index = floor((mouse_rads / TAU) * nb_options) + 1;
			else:
				wheel.selected_options_index = 0;
