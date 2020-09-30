extends Spatial

var _w = false
var _s = false
var _a = false
var _d = false

var _dir_xz = Vector3.ZERO
var _mouse_position = Vector2.ZERO

var speed = 10
var sen = 0.3

var scale_num = 0.5

var scaleSmoothTranslation:Vector3 = Vector3.ZERO
var moveSmoothTranslation:Vector3 = Vector3.ZERO
var smoothRotationY:float = 0.0

onready var privot = get_parent()

var isPressRight:bool

func _ready():
	var target = privot.get_translation()
	set_translation(target)
	privot.rotate_y(deg2rad(45))
	privot.rotate_object_local(Vector3(1,0,0), deg2rad(-45))
	translate(Vector3(0,0,10))
	scaleSmoothTranslation = get_translation()
	moveSmoothTranslation = privot.get_translation()
	smoothRotationY = privot.rotation_degrees.y
	pass

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED or isPressRight:
			_mouse_position = event.relative
		
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_MIDDLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			BUTTON_WHEEL_UP:
				if scaleSmoothTranslation.z + -scale_num < 3:
					return
				scale_num = get_translation().z / 15
#				translate(Vector3(0,0,-scale_num))
				scaleSmoothTranslation += Vector3(0,0,-scale_num)
			BUTTON_WHEEL_DOWN:
				if scaleSmoothTranslation.z + scale_num > 50:
					return
				scale_num = get_translation().z / 15
#				translate(Vector3(0,0,scale_num))
				scaleSmoothTranslation += Vector3(0,0,scale_num)
			BUTTON_RIGHT:
				isPressRight = true if event.pressed else false
				_mouse_position = Vector2.ZERO
	
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
	_update_drag(delta)
	_update_movement(delta)
	_update_look()
	
	#缩放缓动
	self.translation = lerp(self.translation,scaleSmoothTranslation,10*delta)
	
	#移动缓动
	privot.translation = lerp(privot.translation,moveSmoothTranslation,8*delta)
	
	#视角旋转缓动
	privot.rotation.y = lerp_angle(privot.rotation.y,deg2rad(smoothRotationY),10*delta)
	pass

#右键移动相机
func _update_drag(delta):
	if isPressRight:
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_dir_xz = Vector3(-yaw,0,-pitch);
		_dir_xz = Basis(privot.transform.basis.x,privot.transform.basis.y,Vector3(privot.transform.basis.z.x,0,privot.transform.basis.z.z)).xform(_dir_xz)
		_dir_xz = _dir_xz * get_translation().z/3 * delta
#		privot.translation += _dir_xz
		moveSmoothTranslation = moveSmoothTranslation + _dir_xz
		_mouse_position = Vector2.ZERO
		pass
	pass

#w,a,s,d移动相机
func _update_movement(delta):
	speed = get_translation().z
	_dir_xz = Vector3(_d as float - _a as float,0,_s as float - _w as float);
#	privot.translate(_dir_xz)
	
	#1
#	var rotate_x = privot.get_rotation_degrees().x;
#	privot.set_rotation_degrees(Vector3(0,privot.get_rotation_degrees().y,privot.get_rotation_degrees().z))
#	_dir_xz = _dir_xz.normalized() * speed * delta
#	moveSmoothTranslation = moveSmoothTranslation + _dir_xz.rotated(Vector3(0,1,0),privot.get_rotation().y).normalized() * speed * delta
#
##	privot.set_rotation_degrees(Vector3(rotate_x,privot.get_rotation_degrees().y,privot.get_rotation_degrees().z))
#	privot.rotate_object_local(Vector3(1,0,0),deg2rad(rotate_x))
	
	#2
	_dir_xz = Basis(privot.transform.basis.x,privot.transform.basis.y,Vector3(privot.transform.basis.z.x,0,privot.transform.basis.z.z)).xform(_dir_xz)
	_dir_xz = _dir_xz.normalized() * speed * delta
	moveSmoothTranslation = moveSmoothTranslation + _dir_xz
	pass

#中键旋转相机
func _update_look():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sen
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		
		var dist = get_translation().distance_to(Vector3.ZERO)
		set_translation(Vector3.ZERO)
		
#		privot.rotate_y(deg2rad(-yaw))
		smoothRotationY = smoothRotationY + -yaw
			
		translate(Vector3(0,0,dist))
		
		var rotate_x = privot.get_rotation_degrees().x + -pitch
		if rotate_x <= -89 or rotate_x >= -20:
			return
		privot.rotate_object_local(Vector3(1,0,0), deg2rad(-pitch))
	pass
