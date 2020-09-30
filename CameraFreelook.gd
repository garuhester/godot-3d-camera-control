extends Camera

var _w = false
var _s = false
var _a = false
var _d = false
var _shift = false
var _space = false

var _dir_xz = Vector3.ZERO
#var _dir_y = Vector3.ZERO
var _mouse_position = Vector2.ZERO

var speed = 8
var sen = 0.2

var moveSmoothTranslation:Vector3

func _ready():
#	print(0 if true else 1)
	moveSmoothTranslation = self.translation
	pass

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_MIDDLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
	
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
			KEY_SHIFT:
				_shift = event.pressed
			KEY_SPACE:
				_space = event.pressed
	pass

func _process(delta):
	_update_movement(delta)
	_update_look()
	self.translation = lerp(self.translation,moveSmoothTranslation,6*delta)
	pass
	
func _update_movement(delta):
	_dir_xz = Vector3((_d as float - _a as float),(_space as float - _shift as float),(_s as float - _w as float));
	_dir_xz = transform.basis.xform(_dir_xz)
	_dir_xz = _dir_xz.normalized() * speed * delta
	moveSmoothTranslation = moveSmoothTranslation + _dir_xz
#	translate(_dir_xz)
#	_dir_y = Vector3(0,_space as float - _shift as float,0);
#	global_translate(_dir_y.normalized() * speed * delta)
	pass

func _update_look():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sen
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		
		rotate_y(deg2rad(-yaw))

		var r_x = get_rotation_degrees().x + -pitch
		if r_x <= -89 or r_x >= 89:
			return
		rotate_object_local(Vector3(1,0,0), deg2rad(-pitch))
	pass
