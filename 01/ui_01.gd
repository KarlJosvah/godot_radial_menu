extends CanvasLayer;

@onready var radial_menu: Control = $RadialMenu;
@onready var label: Label = $Label;

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("wheel_L"):
		radial_menu.open();
	elif Input.is_action_just_released("wheel_L"):
		var selected_idx = radial_menu.close();
		label.text = "Selected: " + _get_wheel_value(radial_menu, selected_idx);

func _on_radial_menu_on_selection_change(selected_index: int) -> void:
	label.text = "Hovering: " + _get_wheel_value(radial_menu, selected_index);

func _get_wheel_value(wheel_node: Control, index: int) -> String:
	if not wheel_node or not wheel_node.options:
		return "<none>";
	if index < 0 or index >= len(wheel_node.options):
		return "<none>";
	if not wheel_node.options[index]:
		return "<none>";
	return wheel_node.options[index].option_name;
