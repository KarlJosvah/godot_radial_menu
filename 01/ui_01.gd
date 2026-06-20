extends CanvasLayer;

@onready var selection_wheel: Control = $SelectionWheel;
@onready var label: Label = $Label;

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("tool_select"):
		selection_wheel.open();
	elif Input.is_action_just_released("tool_select"):
		var selected_name = selection_wheel.close();
		label.text = selected_name;
		print(selected_name)


func _on_selection_wheel_on_selection_change(selected_name: String) -> void:
	label.text = selected_name;
