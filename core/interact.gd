@tool
extends "res://core/input.gd"

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
