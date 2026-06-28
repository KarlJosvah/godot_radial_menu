@tool
extends Node;

var wheel
var current_linked_index: int = -1

func _ready() -> void:
	if not wheel:
		wheel = get_parent()
	_connect_signals()

func init(wheel_node: Control) -> void:
	wheel = wheel_node
	_connect_signals()

func _connect_signals() -> void:
	if not wheel:
		return
	if not wheel.on_wheel_opened.is_connected(_on_wheel_opened):
		wheel.on_wheel_opened.connect(_on_wheel_opened)
	if not wheel.on_wheel_closed.is_connected(_on_wheel_closed):
		wheel.on_wheel_closed.connect(_on_wheel_closed)
	if not wheel.on_selection_change.is_connected(_on_selection_change):
		wheel.on_selection_change.connect(_on_selection_change)

func _on_wheel_opened() -> void:
	if not wheel.linked_wheel:
		return
	current_linked_index = wheel.selected_options_index
	if current_linked_index != -1 and current_linked_index < wheel.linked_wheels.size():
		var linked = wheel.linked_wheels[current_linked_index]
		if linked:
			linked.open()

func _on_wheel_closed(_selected_index: int) -> void:
	if not wheel.linked_wheel:
		return
	if current_linked_index != -1 and current_linked_index < wheel.linked_wheels.size():
		var linked = wheel.linked_wheels[current_linked_index]
		if linked:
			linked.close()
	current_linked_index = -1

func _on_selection_change(selected_index: int) -> void:
	if not wheel.linked_wheel:
		return
	
	# Close previous linked wheel
	if current_linked_index != -1 and current_linked_index < wheel.linked_wheels.size():
		var linked = wheel.linked_wheels[current_linked_index]
		if linked:
			linked.close()
			
	current_linked_index = selected_index
	
	# Open new linked wheel
	if current_linked_index != -1 and current_linked_index < wheel.linked_wheels.size():
		var linked = wheel.linked_wheels[current_linked_index]
		if linked:
			linked.open()
