extends KinematicBody

var _garbage;

enum TITAN_STATES {
	FOLLOW,
	ATTACK
}

export(NodePath) onready var _hitbox = get_node(_hitbox) as Area

var nav_mesh: NavigationMesh;
var _nav: Navigation;

var state: int;

const move_speed: int = 1000;
const move_acceleration: float = 100.0;
const gravity: float = 9.8;

var target_pos: Vector3;

var path: PoolVector3Array;
var path_index: int = 0;

var velocity: Vector3 = Vector3.ZERO;

const MAX_HIT_POINTS: int = 2;
var hit_points: int = 0;


func _ready():
	_garbage = _hitbox.connect("hit", self, "_on_hit");


func _physics_process(delta):
	if(state == TITAN_STATES.FOLLOW):
		if(path_index < path.size()):
			var path_position: Vector3 = Vector3(path[path_index].x, self.global_transform.origin.y, path[path_index].z)
			var move_dir: Vector3 = (path_position - self.global_transform.origin);
			if(move_dir.length() < 0.1):
				path_index += 1;
			else:
				smooth_look_at(path_position, delta);
				_garbage = self.move_and_slide(move_dir.normalized() * move_speed * delta);
	elif(state == TITAN_STATES.ATTACK):
		pass


func smooth_look_at(pos: Vector3, delta: float) -> void:
	var T: Transform = self.global_transform.looking_at(pos, Vector3.UP);
	self.global_transform = self.global_transform.interpolate_with(T, delta * 5);


func init_pathfinding() -> void:
	state = TITAN_STATES.FOLLOW;
	
	_nav = Navigation.new();
	_garbage = _nav.navmesh_add(nav_mesh, Transform.IDENTITY);
	
	path = _get_path_to(target_pos);


func _get_path_to(destination: Vector3) -> PoolVector3Array:
	path_index = 0;
	return _nav.get_simple_path(self.global_transform.origin, destination);


func _on_hit() -> void:
	hit_points += 1;
	
	if(hit_points >= MAX_HIT_POINTS):
		GameEvents.emit_enemy_killed_signal(self);
		self.queue_free();
