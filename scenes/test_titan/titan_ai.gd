extends KinematicBody

var _garbage;

var _titan_flag;

export(NodePath) onready var _hitbox = get_node(_hitbox) as Area
var _nav_mesh: NavigationMesh = preload("res://resources/nav_meshes/sample_town/R2H8.tres") as NavigationMesh;

var _nav: Navigation;

const move_speed: float = 5.0;
const move_acceleration: float = 100.0;
const gravity: float = 9.8;

var path: PoolVector3Array;
var path_index: int = 0;

var velocity: Vector3 = Vector3.ZERO;

const MAX_HIT_POINTS: int = 2;
var hit_points: int = 0;


func _ready():
	_garbage = _hitbox.connect("hit", self, "_on_hit");
	
	_nav = Navigation.new();
	_garbage = _nav.navmesh_add(_nav_mesh, Transform.IDENTITY);
	
	var target_pos: Position3D = self.get_tree().get_nodes_in_group("target")[0];
	path = _get_path_to(target_pos.global_transform.origin);


func _physics_process(_delta):
	if(path_index < path.size()):
		var path_position: Vector3 = Vector3(path[path_index].x, self.global_transform.origin.y, path[path_index].z)
		var move_dir: Vector3 = (path_position - self.global_transform.origin);
		if(move_dir.length() < 0.1):
			path_index += 1;
		else:
			self.look_at(path_position, Vector3.UP);
			velocity = move_dir.normalized() * move_speed;
			_garbage = self.move_and_slide(velocity);


func _get_path_to(destination: Vector3) -> PoolVector3Array:
	path_index = 0;
	return _nav.get_simple_path(self.global_transform.origin, destination);


func _on_hit() -> void:
	print("I have been hit");
	hit_points += 1;
	
	if(hit_points >= MAX_HIT_POINTS):
		print("I have been killed");
		GameEvents.emit_enemy_killed_signal(self);
		self.queue_free();
