@tool
extends "res://core/interact.gd"

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
