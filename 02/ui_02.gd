extends CanvasLayer;

@onready var wheel_left: Control = $wheel_left;
@onready var wheel_right: Control = $wheel_right;
@onready var wheel_both_left: Control = $wheel_both_left;
#@onready var wheel_both_right: Control = $wheel_both_right;
@onready var wheel_both_rights : Array[Control] = [
	null,
	$wheel_both_rights/wheel_both_right_1,
	$wheel_both_rights/wheel_both_right_2,
	$wheel_both_rights/wheel_both_right_3
];
@onready var label: Label = $Label;

enum Mode {
	NONE,
	LEFT,
	RIGHT,
	BOTH
}
var current_mode = Mode.NONE;
var wheel_both_rights_index : int = 0;

func _process(_delta: float) -> void:
	var l_pressed = Input.is_action_pressed("wheel_L");
	var r_pressed = Input.is_action_pressed("wheel_R");
	
	var target_mode = Mode.NONE;
	if l_pressed and r_pressed:
		target_mode = Mode.BOTH;
	elif l_pressed:
		target_mode = Mode.LEFT;
	elif r_pressed:
		target_mode = Mode.RIGHT;
		
	_change_mode(target_mode);

func _change_mode(new_mode: Mode) -> void:
	if current_mode == new_mode:
		return;
	
	# Close previous mode's wheels
	match current_mode:
		Mode.LEFT:
			var sel = wheel_left.close();
			var text = _get_wheel_value(wheel_left, sel);
			label.text = text;
		Mode.RIGHT:
			var sel : int = wheel_right.close();
			label.text = _get_wheel_value(wheel_right, sel);
		Mode.BOTH:
			var sel_l : int = wheel_both_left.close();
			var sel_r : int = _wheel_both_rights(false);
			var text = _get_wheel_value(wheel_both_left, sel_l);
			if wheel_both_rights_index < len(wheel_both_rights):
				text += " & " +  _get_wheel_value(wheel_both_rights[wheel_both_rights_index], sel_r);
			label.text = text;
			
	current_mode = new_mode;
	
	# Open new mode's wheels
	match current_mode:
		Mode.LEFT:
			wheel_left.open();
		Mode.RIGHT:
			wheel_right.open();
		Mode.BOTH:
			wheel_both_left.open();
			_wheel_both_rights(true);

func _get_wheel_value(wheel : Control, index : int) -> String:
	if not wheel:
		return "<>";
	if not wheel.options:
		return "<>";
	if not index < len(wheel.options):
		return "<>";
	if not wheel.options[index]:
		return "<>";
	return wheel.options[index].option_name;

func _wheel_both_rights(open : bool) -> int:
	if not wheel_both_rights_index < len(wheel_both_rights):
		return -1;
	var wheel = wheel_both_rights[wheel_both_rights_index];
	if not wheel:
		return -1;
	if open:
		wheel.open();
		return -1;
	else:
		return wheel.close();


func _on_wheel_both_left_on_selection_change(selected_index: int) -> void:
	var sel_r : int = _wheel_both_rights(false); # close
	wheel_both_rights_index = selected_index;
	_wheel_both_rights(true); # open
