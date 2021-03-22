extends Spatial

const MAX_TARGET_HEALTH: int = 100;

export(NodePath) onready var _spawn_positions_container = get_node(_spawn_positions_container) as Spatial;
export(Array, NodePath) onready var _titan_targets_paths;

onready var _navmesh: NavigationMesh = preload("res://resources/nav_meshes/sample_level/5m.tres") as NavigationMesh;
onready var _titan_res: Resource = preload("res://scenes/test_titan_no_root/test_titan_no_root.tscn") as Resource;

var spawn_positions: PoolVector3Array = [];
var titan_target_positions: PoolVector3Array = [];
var titans_in_target_area: int = 0;

var target_health: float = MAX_TARGET_HEALTH;


func _ready() -> void:
	for spawn_pos in _spawn_positions_container.get_children():
		spawn_positions.append(spawn_pos.global_transform.origin);
	
	for target_pos in _titan_targets_paths:
		titan_target_positions.append(get_node(target_pos).global_transform.origin);


func _on_SpawnTitan_timeout() -> void:
	var spawn_pos: Vector3 = spawn_positions[randi() % spawn_positions.size()];
	
	var target_pos: Vector3;
	if(titan_target_positions.size() > 1):
		target_pos = titan_target_positions[randi() % titan_target_positions.size()];
	else:
		target_pos = titan_target_positions[0];
	
	var titan_instance = _titan_res.instance();
	self.add_child(titan_instance);
	titan_instance.nav_mesh = _navmesh;
	titan_instance.global_transform.origin = spawn_pos;
	titan_instance.target_pos = target_pos;
	titan_instance.init_pathfinding();
	
	GameEvents.emit_enemy_spawned_signal(titan_instance);
