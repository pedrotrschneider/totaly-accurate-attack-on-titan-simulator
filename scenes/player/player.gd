extends RigidBody

var _garbage;

export (NodePath) onready var head = get_node(head) as Position3D;
export (NodePath) onready var eye = get_node(eye) as Position3D;
export (NodePath) onready var capsule = get_node(capsule) as CollisionShape;
export (NodePath) onready var crosshair_position = get_node(crosshair_position) as Position3D;
export (NodePath) onready var hook_1_origin = get_node(hook_1_origin) as Position3D;
export (NodePath) onready var hook_2_origin = get_node(hook_2_origin) as Position3D;
export (NodePath) onready var bullet_time_cooldown_timer = get_node(bullet_time_cooldown_timer) as Timer;

# Input stuff
var paused: bool = false;
var mouse_sensitivity: float = 0.08;

# Bullet time stuff
const MAX_BULLET_TIME_STAMINA: float = 100.0;
const BULLET_TIME_SCALE: float = 0.1;
var bullet_time: bool = false;
var bullet_time_on_colldown: bool = false;
var bullet_time_stamina: float = MAX_BULLET_TIME_STAMINA;
var bullet_time_consuption: float = 0.1;
var bullet_time_regeneration: float = 0.3;

# Attack stuff
var attack: bool = false;

# Player physics stuff
var input: Vector3 = Vector3.ZERO;
var movement: Vector3 = Vector3.ZERO;
var movement_force: Vector3 = Vector3.ZERO;
var jump_impulse: Vector3 = Vector3.ZERO;
var hook_force: Vector3 = Vector3.ZERO;
var tension_impulse: Vector3 = Vector3.ZERO;

# Movement stuff
const GRAVITY: float = 9.8
const MAX_GROUND_SPEED: float = 5.0
const MAX_MOVEMENT_ACCELERATION: float = 200000.0;
var movement_acceleration: float = MAX_MOVEMENT_ACCELERATION;
var set_new_pos: bool = false;
var new_pos: Vector3 = Vector3.ZERO;

# Jump stuff
var can_jump: bool = true;
var jump_magnitude: float = 600.0;

# Hook stuff
const MAX_GAS_AMOUNT: float = 500.0;
const GASD_DEPLETION: float = 0.1;
const HOOK_LENGTH: float = 45.0;
const HOOK_POTENCY: float = 3e+06;
const MAX_GRAPPLE_SPEED: float = 20.0;
enum HOOK_STATES{
	READY, 
	SHOOT, 
	GRAPPLED, 
	REWINDING
}
onready  var rope_prefab = preload("res://scenes/player/rope/rope.tscn");
var activate_motor: bool = false;
var gas_amount: float = MAX_GAS_AMOUNT;

var hook_1_interaction: bool = false;
var hook_1_release: bool = false;
var hook_1 = HOOK_STATES.READY;
var hook_1_grapple_position: Position3D;
var hook_1_gappled_object: Object;
var hook_1_rope: Position3D;

var hook_2_interaction: bool = false;
var hook_2_release: bool = false;
var hook_2 = HOOK_STATES.READY;
var hook_2_grapple_position: Position3D;
var hook_2_gappled_object: Object;
var hook_2_rope: Position3D;


####################################
#           Utilities              #
####################################

func remap_range(value: float, min_in_range: float, max_in_range: float, min_out_range: float, max_out_range: float) -> float:
	return (value - min_in_range) / (max_in_range - min_in_range) * (max_out_range - min_out_range) + min_out_range


func is_grounded() -> bool:
	var num_rays: int = 9;
	var sep_rad: float = deg2rad(360 / float(num_rays - 1));
	var capsule_radius: float = capsule.shape.radius;
	var capsule_heihgt: float = capsule.shape.height;
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
		collision = direct_state.intersect_ray(ray, ray + Vector3(0.0, - (capsule_heihgt + 0.5), 0.0), [], 1);
		if (collision):
			break;
	
	if (collision):
		return true;
	return false;


func scan_hook_hit() -> Dictionary:
	var direct_state:PhysicsDirectSpaceState = get_world().direct_space_state;
	var direction:Vector3 = (crosshair_position.global_transform.origin - eye.global_transform.origin).normalized();
	return direct_state.intersect_ray(eye.global_transform.origin, eye.global_transform.origin + direction * HOOK_LENGTH, [], 16);


####################################
#          Callbacks               #
####################################

func _ready() -> void :
	_garbage = GameEvents.connect("pause", self, "_on_pause");
	_garbage = GameEvents.connect("unpause", self, "_on_unpause");
	_garbage = GameEvents.connect("enemy_killed", self, "_on_enemy_killed");
	_garbage = GameEvents.connect("respawn_player", self, "_on_respawn_player");
	_garbage = bullet_time_cooldown_timer.connect("timeout", self, "_on_bullet_time_cooldown_timer_timeout");
	
	var physics_material:PhysicsMaterial = PhysicsMaterial.new();
	physics_material.set_friction(2.0);
	physics_material.set_rough(true);
	self.physics_material_override = physics_material;


func _input(event) -> void:
	if(paused):
		return;
	
	# Camera pitch and yaw input
	if event is InputEventMouseMotion:
		rotate_y(deg2rad( - event.relative.x * mouse_sensitivity));
		head.rotate_x(deg2rad( - event.relative.y * mouse_sensitivity));
		head.rotation.x = clamp(head.rotation.x, deg2rad( - 89), deg2rad(89));


func _integrate_forces(state):
	# If we need to change the player's position
	if(set_new_pos):
		set_new_pos = false;
		state.transform.origin = new_pos;
		new_pos = Vector3.ZERO;
	
	# Add movement force
	if(hook_1 != HOOK_STATES.REWINDING && hook_2 != HOOK_STATES.REWINDING):
		self.add_central_force(movement_force);
	
	# Add jump impulse
	self.apply_central_impulse(jump_impulse);
	
	# Add hook force
	self.add_central_force(hook_force);
	
	# Limit the linear speed of the body
	if (state.linear_velocity.length() > MAX_GRAPPLE_SPEED):
		state.linear_velocity = state.linear_velocity.normalized() * MAX_GRAPPLE_SPEED;
	
	# Add rope tension impulse
	tension_impulse = Vector3.ZERO;
	
	if(hook_1_grapple_position):
		if((hook_1 == HOOK_STATES.GRAPPLED || hook_1 == HOOK_STATES.REWINDING)\
			&& activate_motor && hook_2 != HOOK_STATES.REWINDING):
			var dir: Vector3 = (hook_1_grapple_position.global_transform.origin - self.global_transform.origin).normalized();
			var partial_tension_impulse: Vector3 = dir.dot(state.linear_velocity) * (-dir);
			if(partial_tension_impulse.normalized().dot(dir) > 0):
				tension_impulse += partial_tension_impulse;
	
	if(hook_2_grapple_position):
		if((hook_2 == HOOK_STATES.GRAPPLED || hook_2 == HOOK_STATES.REWINDING)\
		&& activate_motor && hook_1 != HOOK_STATES.REWINDING):
			var dir: Vector3 = (hook_2_grapple_position.global_transform.origin - self.global_transform.origin).normalized();
			var partial_tension_impulse: Vector3 = dir.dot(state.linear_velocity) * (-dir);
			if(partial_tension_impulse.normalized().dot(dir) > 0):
				tension_impulse += partial_tension_impulse;
	
	self.apply_central_impulse(tension_impulse * self.mass);


func _physics_process(delta) -> void:
	if(paused):
		return;
	
	# Handle input
	get_input();
	
	# Handle bullet time
	Engine.time_scale = 1.0;
	if(!bullet_time_on_colldown):
		if(bullet_time):
			Engine.time_scale = BULLET_TIME_SCALE;
			bullet_time_stamina -= bullet_time_consuption;
		else:
			bullet_time_stamina += bullet_time_regeneration;
			bullet_time_stamina = clamp(bullet_time_stamina, 0, MAX_BULLET_TIME_STAMINA);
		if(bullet_time_stamina <= 0):
			bullet_time_on_colldown = true;
			bullet_time_cooldown_timer.start();
	
	# Handle attack
	if(attack):
		GameEvents.emit_attack_signal();
	
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
	else:
		can_jump = false;
	
	jump_impulse = Vector3.ZERO;
	if (input.y > 0 && can_jump):
		can_jump = false;
		jump_impulse = Vector3.UP * jump_magnitude;
	
	# Handle hook
	hook(delta);


func _on_enemy_killed(object: Object) -> void:
	if(hook_1_grapple_position && object.is_a_parent_of(hook_1_grapple_position)):
		hook_1_release = true;
	
	if(hook_2_grapple_position && object.is_a_parent_of(hook_2_grapple_position)):
		hook_2_release = true;
	
	hook(0);


func _on_respawn_player(position: Vector3) -> void:
	set_new_pos = true;
	new_pos = position


func _on_bullet_time_cooldown_timer_timeout() -> void:
	bullet_time_on_colldown = false;


func _on_pause() -> void:
	paused = true;


func _on_unpause() -> void:
	paused = false;
####################################
#           Handlers               #
####################################

func get_input() -> void:
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
	activate_motor = Input.is_action_pressed("activate_motor");
	
	# Hook 1
	var hook_1_just_pressed: bool = Input.is_action_just_pressed("hook_1");
	var hook_1_just_released: bool = Input.is_action_just_released("hook_1")
	
	if(activate_motor):
		if(hook_1_just_pressed):
			hook_1_interaction = true;
		elif(hook_1_just_released):
			hook_1_interaction = false;
	else:
		hook_1_interaction = false;
		if(hook_1_just_pressed):
			hook_1_interaction = true;
			if(hook_1 == HOOK_STATES.GRAPPLED):
				hook_1_release = true;
				hook_1_interaction = false;
		elif(hook_1_just_released):
			hook_1_interaction = false;
	
	# Hook 2
	var hook_2_just_pressed: bool = Input.is_action_just_pressed("hook_2");
	var hook_2_just_released: bool = Input.is_action_just_released("hook_2")
	
	if(activate_motor):
		if(hook_2_just_pressed):
			hook_2_interaction = true;
		elif(hook_2_just_released):
			hook_2_interaction = false;
	else:
		if(hook_2_just_pressed):
			hook_2_interaction = true;
			if(hook_2 == HOOK_STATES.GRAPPLED):
				hook_2_release = true;
				hook_2_interaction = false;
		elif(hook_2_just_released):
			hook_2_interaction = false;
	
	# Bullet time input
	bullet_time = Input.is_action_pressed("bullet_time");
	
	# Attack Input
	attack = Input.is_action_just_pressed("attack");


func hook(delta:float) -> void:
	gas_amount = min(gas_amount, MAX_GAS_AMOUNT);
	
	hook_force = Vector3.ZERO;
	
	# Hook 1
	if(!hook_1_grapple_position && hook_1 != HOOK_STATES.READY):
		hook_1_release = true;
	
	if (hook_1_release):
		if(hook_1_grapple_position):
			hook_1_grapple_position.call_deferred("queue_free");
		hook_1_rope.call_deferred("queue_free");
		hook_1_interaction = false;
		hook_1_release = false;
		hook_1 = HOOK_STATES.READY;
	
	if (hook_1 == HOOK_STATES.READY):
		if (hook_1_interaction):
			hook_1 = HOOK_STATES.SHOOT;
	
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
		if (hook_1_interaction && hook_1_grapple_position):
			gas_amount = max(gas_amount - GASD_DEPLETION, 0);
			var direction:Vector3 = (hook_1_grapple_position.global_transform.origin - self.global_transform.origin).normalized();
			var gas_multilpier: float = 1.0;
			if(gas_amount == 0):
				gas_multilpier = 0.1;
			hook_force += direction * HOOK_POTENCY * gas_multilpier * delta;
		else :
			hook_1 = HOOK_STATES.GRAPPLED;
	
	# Hook 2
	if(!hook_2_grapple_position && hook_2 != HOOK_STATES.READY):
		hook_2_release = true;
	
	if (hook_2_release):
		if(hook_2_grapple_position):
			hook_2_grapple_position.call_deferred("queue_free");
		hook_2_rope.call_deferred("queue_free");
		hook_2_interaction = false;
		hook_2_release = false;
		hook_2 = HOOK_STATES.READY;
	
	if (hook_2 == HOOK_STATES.READY):
		if (hook_2_interaction):
			hook_2 = HOOK_STATES.SHOOT;
	
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
		if (hook_2_interaction && hook_2_grapple_position):
			gas_amount = max(gas_amount - GASD_DEPLETION, 0);
			var direction:Vector3 = (hook_2_grapple_position.global_transform.origin - self.global_transform.origin).normalized();
			var gas_multilpier: float = 1.0;
			if(gas_amount == 0):
				gas_multilpier = 0.1;
			hook_force += direction * HOOK_POTENCY * gas_multilpier * delta;
		else:
			hook_2 = HOOK_STATES.GRAPPLED;
