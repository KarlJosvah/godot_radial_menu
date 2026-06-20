extends CanvasLayer;

@onready var selection_wheel: Control = $SelectionWheel;
@onready var label: Label = $Label;

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("wheel_L"):
		selection_wheel.open();
	elif Input.is_action_just_released("wheel_L"):
		var selected_name = selection_wheel.close();
		label.text = selected_name;


func _on_selection_wheel_on_selection_change(selected_name: String) -> void:
	label.text = selected_name;
