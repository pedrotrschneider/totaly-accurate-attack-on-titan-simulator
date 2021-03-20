extends RigidBody

export (NodePath) onready  var head = get_node(head) as Position3D;
export (NodePath) onready  var eye = get_node(eye) as Position3D;
export (NodePath) onready  var capsule = get_node(capsule) as MeshInstance;
export (NodePath) onready  var crosshair_position = get_node(crosshair_position) as Position3D;
export (NodePath) onready  var hook_1_origin = get_node(hook_1_origin) as Position3D;
export (NodePath) onready  var hook_2_origin = get_node(hook_2_origin) as Position3D;

# Mouse stuff
var mouse_sensitivity: float = 0.08;

# Player physics stuff
var input: Vector3 = Vector3.ZERO;
var movement: Vector3 = Vector3.ZERO;
var movement_force: Vector3 = Vector3.ZERO;
var jump_impulse: Vector3 = Vector3.ZERO;
var hook_force: Vector3 = Vector3.ZERO;

# Movement stuff
const MAX_GROUND_SPEED: float = 5.0
const MAX_MOVEMENT_ACCELERATION: float = 200000.0;
var movement_acceleration: float = MAX_MOVEMENT_ACCELERATION;

# Jum stuff
var can_jump: bool = true;
var jump_magnitude: float = 600.0;

# Hook stuff
const HOOK_LENGTH: float = 100.0;
const HOOK_POTENCY: float = 3e+06;
const MAX_GRAPPLE_SPEED: float = 20.0;
enum HOOK_STATES{
	READY, 
	SHOOT, 
	GRAPPLED, 
	REWINDING
}
onready  var rope_prefab = preload("res://scenes/rope/rope.tscn");

var hook_1_interaction:bool = false;
var hook_1_release:bool = false;
var hook_1 = HOOK_STATES.READY;
var hook_1_grapple_position:Position3D;
var hook_1_gappled_object;
var hook_1_rope:Position3D;

var hook_2_interaction:bool = false;
var hook_2_release:bool = false;
var hook_2 = HOOK_STATES.READY;
var hook_2_grapple_position:Position3D;
var hook_2_gappled_object;
var hook_2_rope:Position3D;


####################################
#           Utilities              #
####################################

func remap_range(value: float, min_in_range: float, max_in_range: float, min_out_range: float, max_out_range: float) -> float:
	return (value - min_in_range) / (max_in_range - min_in_range) * (max_out_range - min_out_range) + min_out_range


func is_grounded() -> bool:
	var num_rays: int = 9;
	var sep_rad: float = deg2rad(360 / float(num_rays - 1));
	var capsule_radius: float = capsule.mesh.radius;
	var capsule_heihgt: float = capsule.mesh.mid_height;
	var ray_positions: Array = PoolVector3Array();
	
	for i in num_rays - 1:
		ray_positions.append(Vector3(
			self.global_transform.origin.x + sin(sep_rad * i) * capsule_radius, 
			self.global_transform.origin.y, 
			self.global_transform.origin.z + cos(sep_rad * i) * capsule_radius
		));
	ray_positions.append(Vector3(
		self.global_transform.origin.x, 
		self.global_transform.origin.y, 
		self.global_transform.origin.z
	));
	
	var direct_state: PhysicsDirectSpaceState = get_world().direct_space_state;
	var collision: Dictionary;
	for ray in ray_positions:
		collision = direct_state.intersect_ray(ray, ray + Vector3(0.0, - (capsule_heihgt + 0.0005), 0.0));
		if (collision):
			break;
	
	if (collision):
		return true;
	return false;


func scan_hook_hit() -> Dictionary:
	var direct_state:PhysicsDirectSpaceState = get_world().direct_space_state;
	var direction:Vector3 = (crosshair_position.global_transform.origin - eye.global_transform.origin).normalized();
	return direct_state.intersect_ray(eye.global_transform.origin, eye.global_transform.origin + direction * HOOK_LENGTH);


####################################
#          Callbacks               #
####################################

func _input(event) -> void :
	# Camera pitch and yaw input
	if event is InputEventMouseMotion:
		rotate_y(deg2rad( - event.relative.x * mouse_sensitivity));
		head.rotate_x(deg2rad( - event.relative.y * mouse_sensitivity));
		head.rotation.x = clamp(head.rotation.x, deg2rad( - 89), deg2rad(89));


func _integrate_forces(state):
	# Add movement force
	self.add_central_force(movement_force);
	
	# Add jump impulse
	self.apply_central_impulse(jump_impulse);
	
	# Add hook force
	self.add_central_force(hook_force);
	
	# Limit the linear speed of the body
	if (state.linear_velocity.length() > MAX_GRAPPLE_SPEED):
		state.linear_velocity = state.linear_velocity.normalized() * MAX_GRAPPLE_SPEED;


func _ready() -> void :
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	var physics_material:PhysicsMaterial = PhysicsMaterial.new();
	physics_material.set_friction(2.0);
	physics_material.set_rough(true);
	self.physics_material_override = physics_material;


func _physics_process(delta) -> void :
	# Handle input
	get_input();
	
	# Handle movement
	var is_on_ground:bool = is_grounded();
	
	movement_force = Vector3.ZERO;
	if (is_on_ground):
		# Limit acceleration based on current linear speed
		var linear_speed = Vector2(self.linear_velocity.x, self.linear_velocity.z).length();
		movement_acceleration = remap_range(linear_speed / MAX_GROUND_SPEED, 0.0, 1.0, MAX_MOVEMENT_ACCELERATION, 0.0);
		
		# Calculate movement force
		movement_force += self.mass * movement * movement_acceleration * delta;
	
	# Handle jump
	if (is_on_ground):
		can_jump = true;
	else :
		can_jump = false;
	
	jump_impulse = Vector3.ZERO;
	if (input.y > 0 and can_jump):
		can_jump = false;
		jump_impulse = Vector3.UP * jump_magnitude;
	
	# Handle hook
	hook(delta);


####################################
#           Handlers               #
####################################

func get_input() -> void:
	# Mouse visibility input
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	# Movement input
	input = Vector3.ZERO;
	input.z -= int(Input.is_action_pressed("forward"));
	input.z += int(Input.is_action_pressed("backward"));
	input.x -= int(Input.is_action_pressed("left"));
	input.x += int(Input.is_action_pressed("right"));
	input.y = int(Input.is_action_just_pressed("jump"));
	
	movement = Vector3.ZERO;
	movement += self.transform.basis.z * input.z;
	movement += self.transform.basis.x * input.x;
	movement = movement.normalized();
	
	# Hook input
	# Hook 1
	if (Input.is_action_pressed("hook_1") and Input.is_action_just_pressed("release_hook") or Input.is_action_pressed("release_hook") and Input.is_action_just_pressed("hook_1")):
		hook_1_release = true;
	
	if (Input.is_action_just_pressed("hook_1")):
		hook_1_interaction = true;
	elif (Input.is_action_just_released("hook_1")):
		hook_1_interaction = false;
	
	# Hook 2
	if (Input.is_action_pressed("hook_2") and Input.is_action_just_pressed("release_hook") or Input.is_action_pressed("release_hook") and Input.is_action_just_pressed("hook_2")):
		hook_2_release = true;
	
	if (Input.is_action_just_pressed("hook_2")):
		hook_2_interaction = true;
	if (Input.is_action_just_released("hook_2")):
		hook_2_interaction = false;


func hook(delta:float)->void :
	hook_force = Vector3.ZERO;
	
	# Hook 1
	if (hook_1 == HOOK_STATES.READY):
		if (hook_1_interaction):
			hook_1 = HOOK_STATES.SHOOT;
	elif (hook_1_release):
		hook_1_grapple_position.queue_free();
		hook_1_rope.queue_free();
		hook_1_interaction = false;
		hook_1_release = false;
		hook_1 = HOOK_STATES.READY;
	
	if (hook_1 == HOOK_STATES.SHOOT):
		var collision:Dictionary = scan_hook_hit();
		if (collision):
			hook_1_grapple_position = Position3D.new();
			hook_1_gappled_object = collision.collider;
			hook_1_gappled_object.add_child(hook_1_grapple_position);
			hook_1_grapple_position.global_transform.origin = collision.position;
			
			hook_1_rope = rope_prefab.instance();
			hook_1_origin.add_child(hook_1_rope);
			hook_1_rope.end_point = hook_1_grapple_position;
			
			hook_1 = HOOK_STATES.GRAPPLED;
			hook_1_interaction = false;
		else :
			hook_1 = HOOK_STATES.READY;
			hook_1_interaction = false;
	
	elif (hook_1 == HOOK_STATES.GRAPPLED):
		if (hook_1_interaction):
			hook_1 = HOOK_STATES.REWINDING;

	elif (hook_1 == HOOK_STATES.REWINDING):
		if (hook_1_interaction):
			var direction:Vector3 = (hook_1_grapple_position.global_transform.origin - self.global_transform.origin).normalized();
			hook_force += direction * HOOK_POTENCY * delta;
		else :
			hook_1 = HOOK_STATES.GRAPPLED;
	
	# Hook 2
	if (hook_2 == HOOK_STATES.READY):
		if (hook_2_interaction):
			hook_2 = HOOK_STATES.SHOOT;
	elif (hook_2_release):
		hook_2_grapple_position.queue_free();
		hook_2_rope.queue_free();
		hook_2_interaction = false;
		hook_2_release = false;
		hook_2 = HOOK_STATES.READY;
	
	if (hook_2 == HOOK_STATES.SHOOT):
		var collision:Dictionary = scan_hook_hit();
		if (collision):
			hook_2_grapple_position = Position3D.new();
			hook_2_gappled_object = collision.collider;
			hook_2_gappled_object.add_child(hook_2_grapple_position);
			hook_2_grapple_position.global_transform.origin = collision.position;
			
			hook_2_rope = rope_prefab.instance();
			hook_2_origin.add_child(hook_2_rope);
			hook_2_rope.end_point = hook_2_grapple_position;
			
			hook_2 = HOOK_STATES.GRAPPLED;
			hook_2_interaction = false;
		else :
			hook_2 = HOOK_STATES.READY;
			hook_2_interaction = false;
	
	elif (hook_2 == HOOK_STATES.GRAPPLED):
		if (hook_2_interaction):
			hook_2 = HOOK_STATES.REWINDING;

	elif (hook_2 == HOOK_STATES.REWINDING):
		if (hook_2_interaction):
			var direction:Vector3 = (hook_2_grapple_position.global_transform.origin - self.global_transform.origin).normalized();
			hook_force += direction * HOOK_POTENCY * delta;
		else :
			hook_2 = HOOK_STATES.GRAPPLED;
