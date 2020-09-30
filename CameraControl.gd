extends Camera

var _w = false
var _s = false
var _a = false
var _d = false

var _dir_xz = Vector3.ZERO
var _mouse_position = Vector2.ZERO

var speed = 10
var sen = 0.2

var r_x

var scale_num = 0.5

onready var privot = $privot

func _ready():
	privot.set_translation(Vector3(0,0,-7))
#	print(0 if true else 1)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_MIDDLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			BUTTON_WHEEL_UP:
				if get_translation().y >= 10:
					scale_num = 1.5
				elif get_translation().y <= 3:
					scale_num = 0.2
				else:
					scale_num = 0.5
				translate(Vector3(0,0,-scale_num))
			BUTTON_WHEEL_DOWN:
				if get_translation().y >= 10:
					scale_num = 1.5
				elif get_translation().y <= 3:
					scale_num = 0.2
				else:
					scale_num = 0.5
				translate(Vector3(0,0,scale_num))
	
	if event is InputEventKey:
		match event.scancode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
	pass

func _process(delta):
	_update_movement(delta)
	_update_look()
	pass
	
func _update_movement(delta):
	_dir_xz = Vector3(_d as float - _a as float,0,_s as float - _w as float);
	r_x = get_rotation_degrees().x;
	set_rotation_degrees(Vector3(0,get_rotation_degrees().y,get_rotation_degrees().z))
	translate(_dir_xz.normalized() * speed * delta)
	rotate_object_local(Vector3(1,0,0),deg2rad(r_x))
	pass

func _update_look():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sen
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		
		var r_x = get_rotation_degrees().x + -pitch
		if r_x <= -89 or r_x >= 89:
			return
		
		var target = to_global(privot.get_translation())
		var dist = get_translation().distance_to(target)
		
		set_translation(target)
		rotate_y(deg2rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg2rad(-pitch))
		translate(Vector3(0,0,dist))
	pass
