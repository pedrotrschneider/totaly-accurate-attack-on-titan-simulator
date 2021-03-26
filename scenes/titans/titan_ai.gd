extends KinematicBody

var _garbage;

enum TITAN_STATES {
	POOL,
	FOLLOW,
	ATTACK
}

export(NodePath) onready var _anim_tree = get_node(_anim_tree) as AnimationTree;
export(NodePath) onready var _hitbox = get_node(_hitbox) as Area
export(NodePath) onready var _attack_timer = get_node(_attack_timer) as Timer;

var nav_mesh: NavigationMesh;
var _nav: Navigation;

var state: int;

const move_speed: float = 4.0;
const gravity: float = 9.8;

var target_pos: Vector3;

var path: Array;
var path_index: int = 0;

var velocity: Vector3 = Vector3.ZERO;

const MAX_HIT_POINTS: int = 2;
var hit_points: int = 0;

var damage: float = 10;

var anim_state_machine;
var walk_animation: String = "w";
var attack_animation: String = "a";

signal attack_target(damage);


func _ready():
	_garbage = _hitbox.connect("hit", self, "_on_hit");
	_garbage = _attack_timer.connect("timeout", self, "_on_AttackTimer_timeout");
	
	self.add_to_group("enemy");
	
	anim_state_machine = _anim_tree["parameters/playback"];

func _physics_process(delta):
	if(state == TITAN_STATES.FOLLOW):
		if(path_index < path.size()):
			var path_position: Vector3 = Vector3(path[path_index].x, self.global_transform.origin.y, path[path_index].z)
			var move_dir: Vector3 = (path_position - self.global_transform.origin);
			if(move_dir.length() < 0.1):
				path_index += 1;
			else:
				smooth_look_at(path_position, delta);
				_garbage = self.move_and_slide(move_dir.normalized() * move_speed);
	elif(state == TITAN_STATES.ATTACK):
		smooth_look_at(target_pos, delta);
		if(_attack_timer.is_stopped()):
			_attack_timer.start();


func smooth_look_at(pos: Vector3, delta: float) -> void:
	var T: Transform = self.global_transform.looking_at(pos, Vector3.UP);
	self.global_transform = self.global_transform.interpolate_with(T, delta * 5);


func init_pathfinding() -> void:
	self.show();
	
	var walk_animation_index: int = randi() % 6 + 1;
	var attack_animation_index: int = randi() % 2 + 1;

	walk_animation += str(walk_animation_index);
	attack_animation += str(attack_animation_index);
	
	anim_state_machine.start(walk_animation);
	
	state = TITAN_STATES.FOLLOW;
	
	_nav = Navigation.new();
	_garbage = _nav.navmesh_add(nav_mesh, Transform.IDENTITY);
	
	path = _get_path_to(target_pos);


func stop_pathfinding() -> void:
	state = TITAN_STATES.POOL;
	path.clear();
	target_pos = Vector3.ZERO;
	path_index = 0;


func _get_path_to(destination: Vector3) -> PoolVector3Array:
	path_index = 0;
	return _nav.get_simple_path(self.global_transform.origin, destination);


func _on_hit() -> void:
	hit_points += 1;
	
	if(hit_points >= MAX_HIT_POINTS):
		self.hide();
		self.set_process(false);
		self.set_physics_process_internal(false);
		self.set_process_input(false);
		stop_pathfinding();
		GameEvents.emit_enemy_killed_signal(self);


func got_to_target() -> void:
	state = TITAN_STATES.ATTACK;
	anim_state_machine.travel(attack_animation);


func _on_AttackTimer_timeout():
	print("signal emitted")
	self.emit_signal("attack_target", damage);
