extends CanvasLayer;

@onready var wheel_left: Control = $wheel_left;
@onready var wheel_right: Control = $wheel_right;
@onready var wheel_both_left: Control = $wheel_both_left;
@onready var wheel_both_right: Control = $wheel_both_right;
@onready var label: Label = $Label;

enum Mode {
	NONE,
	LEFT,
	RIGHT,
	BOTH
}
var current_mode = Mode.NONE;

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
			label.text = sel;
			print(sel);
		Mode.RIGHT:
			var sel = wheel_right.close();
			label.text = sel;
			print(sel);
		Mode.BOTH:
			var sel_l = wheel_both_left.close();
			var sel_r = wheel_both_right.close();
			label.text = sel_l + " & " + sel_r;
			print(sel_l + " & " + sel_r);
			
	current_mode = new_mode;
	
	# Open new mode's wheels
	match current_mode:
		Mode.LEFT:
			wheel_left.open();
		Mode.RIGHT:
			wheel_right.open();
		Mode.BOTH:
			wheel_both_left.open();
			wheel_both_right.open();
