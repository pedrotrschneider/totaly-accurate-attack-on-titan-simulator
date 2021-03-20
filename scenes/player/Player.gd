extends KinematicBody























































onready  var head:Position3D = $Head
onready  var capsule:MeshInstance = $Mesh
var mouse_sensitivity:float = 0.1;


var input:Vector3 = Vector3.ZERO;
var movement:Vector3 = Vector3.ZERO;
var acceleration:Vector3 = Vector3.ZERO;
var velocity:Vector3 = Vector3.ZERO;
var air_friction:Vector3 = Vector3(1.0, 1.0, 1.0);
var ground_friction:Vector3 = Vector3(1.0, 0.0, 1.0);


export  var movement_acceleration:float = 50.0;
export  var max_move_speed:float = 8.0;
export  var gravity:float = 9.8 * 3.0;
export  var max_fall_speed:float = 20.0;
export  var jump_impulse:float = 300.0;
export  var air_control:float = 0.1;


export  var air_coeficient_friction:float = 5.0;
export  var ground_coeficient_friction:float = 70.0;


func _ready()->void :
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


func _input(event)->void :
	if event is InputEventMouseMotion:
		rotate_y(deg2rad( - event.relative.x * mouse_sensitivity));
		head.rotate_x(deg2rad( - event.relative.y * mouse_sensitivity));
		head.rotation.x = clamp(head.rotation.x, deg2rad( - 89), deg2rad(89));


func get_input()->void :
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	input = Vector3.ZERO;
	input.z -= int(Input.is_action_pressed("forward"));
	input.z += int(Input.is_action_pressed("backward"));
	input.x -= int(Input.is_action_pressed("left"));
	input.x += int(Input.is_action_pressed("right"));
	input.y = int(Input.is_action_pressed("jump"));
	
	movement = Vector3.ZERO;
	movement += self.transform.basis.z * input.z;
	movement += self.transform.basis.x * input.x;


func _physics_process(delta)->void :
	get_input();
	var is_grounded = is_grounded();
	
	acceleration = Vector3.ZERO;
	update_acceleration(is_grounded);
	if (input.y > 0 and is_grounded):
		input.y = 0;
		apply_impulse(Vector3.UP * jump_impulse);
	update_velocity(delta);
	
	print(acceleration);
	
	move_and_slide(velocity, Vector3.UP);


func update_acceleration(is_grounded)->void :
	acceleration += movement * movement_acceleration;
	if ( not is_grounded):
		acceleration *= air_control;
	
	if ( not is_grounded):
		acceleration.y -= gravity;
	else :
		acceleration.y = 0
	
	if (is_grounded):
		acceleration -= ground_friction * ground_coeficient_friction * velocity.normalized();
	else :
		acceleration -= air_friction * air_coeficient_friction * velocity.normalized();


func update_velocity(delta:float)->void :
	velocity += acceleration * delta;
	
	var max_h_vel:Vector2 = Vector2(abs(velocity.x), abs(velocity.z)).normalized() * max_move_speed;
	velocity.x = clamp(velocity.x, - max_h_vel.x, max_h_vel.x);
	velocity.z = clamp(velocity.z, - max_h_vel.y, max_h_vel.y);
	
	var velocity_minimum:float = 0.1;
	if (abs(velocity.x) < velocity_minimum):
		velocity.x = 0;
	if (abs(velocity.y) < velocity_minimum):
		velocity.y = 0;
	if (abs(velocity.z) < velocity_minimum):
		velocity.z = 0;


func apply_impulse(impulse:Vector3)->void :
	acceleration += impulse;


func is_grounded()->bool:
	var num_rays:int = 9;
	var sep_rad:float = deg2rad(360 / float(num_rays - 1));
	var capsule_radius = capsule.mesh.radius;
	var capsule_heihgt = capsule.mesh.mid_height;
	var ray_positions:Array = PoolVector3Array();
	
	for i in num_rays - 1:
		ray_positions.append(Vector3(
			self.global_transform.origin.x + sin(sep_rad * i) * capsule_radius, 
			self.global_transform.origin.y, 
			self.global_transform.origin.z + cos(sep_rad * i) * capsule_radius)
		);
	ray_positions.append(Vector3(
		self.global_transform.origin.x, 
		self.global_transform.origin.y, 
		self.global_transform.origin.z
	));
	
	var direct_state:PhysicsDirectSpaceState = get_world().direct_space_state;
	var collision = null;
	for ray in ray_positions:
		collision = direct_state.intersect_ray(ray, ray + Vector3(0.0, - (capsule_heihgt + 0.005), 0.0));
		if (collision):
			break;
	
	if (collision):
		return true;
	return false;
