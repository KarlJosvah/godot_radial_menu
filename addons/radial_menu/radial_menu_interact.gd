@tool
extends Node

var wheel: Control

func _ready() -> void:
	if not wheel:
		wheel = get_parent()

func init(wheel_node: Control) -> void:
	wheel = wheel_node

func open() -> void:
	if not wheel:
		return
	wheel.is_opened = true;
	toggle_visibility();
	wheel.previous_mouse_mode = Input.mouse_mode;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	wheel.virtual_mouse_pos = Vector2.ZERO;
	wheel.using_joypad = false;
	wheel.last_joypad_push_time = 0;
	wheel.last_non_zero_selected_index = 0;
	wheel.on_wheel_opened.emit();

func close() -> int:
	if not wheel:
		return -1
	wheel.is_opened = false;
	toggle_visibility();
	Input.mouse_mode = wheel.previous_mouse_mode;
	
	var selected_index : int = -1;
	if wheel.selected_options_index < len(wheel.options) and wheel.options[wheel.selected_options_index]:
		selected_index = wheel.selected_options_index;
	wheel.on_wheel_closed.emit(selected_index);
	return selected_index;

func toggle_visibility() -> void:
	if not wheel:
		return
	if wheel.transition_tween and wheel.transition_tween.is_running():
		wheel.transition_tween.kill();
	
	var ease_in: float = wheel.ease_in_speed if wheel.animation else 0.0;
	var ease_out: float = wheel.ease_out_speed if wheel.animation else 0.0;
	if wheel.is_opened:
		wheel.show();
		wheel.transition_tween = wheel.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
		wheel.transition_tween.tween_property(wheel , "scale", Vector2.ONE, ease_in);
	else:
		wheel.transition_tween = wheel.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD);
		wheel.transition_tween.tween_property(wheel , "scale", Vector2.ZERO, ease_out);
		wheel.transition_tween.tween_callback(func(): wheel.visible = false);
