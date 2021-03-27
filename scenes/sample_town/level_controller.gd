extends Spatial

var _garbage;

const MAX_TARGET_HEALTH: int = 100;

export(NodePath) onready var _spawn_positions_container = get_node(_spawn_positions_container) as Spatial;
export(Array, NodePath) onready var _titan_targets_paths;

#onready var _navmesh: NavigationMesh = preload("res://resources/nav_meshes/sample_level/5m.tres") as NavigationMesh;
#onready var _titan_res: Resource = preload("res://scenes/test_titan_no_root/test_titan_no_root.tscn") as Resource

onready var _navmeshes: Array = [
	preload("res://resources/nav_meshes/sample_town/5m.tres"),
	preload("res://resources/nav_meshes/sample_town/7m.tres"),
	preload("res://resources/nav_meshes/sample_town/15m.tres"),
	preload("res://resources/nav_meshes/sample_town/15m.tres"),
	preload("res://resources/nav_meshes/sample_town/20m.tres")
]

onready var _titans_res: Array = [
	[ # 5m titans
		preload("res://scenes/titans/5m/5m1.tscn"),
		preload("res://scenes/titans/5m/5m2.tscn"),
		preload("res://scenes/titans/5m/5m3.tscn")
	],
	[ # 7m titans
		preload("res://scenes/titans/7m/7m1.tscn"),
		preload("res://scenes/titans/7m/7m2.tscn"),
		preload("res://scenes/titans/7m/7m3.tscn")
	],
	[ # 12m titans
		preload("res://scenes/titans/12m/12m1.tscn"),
		preload("res://scenes/titans/12m/12m2.tscn"),
		preload("res://scenes/titans/12m/12m3.tscn")
	],
	[ # 15m titans
		preload("res://scenes/titans/15m/15m1.tscn"),
		preload("res://scenes/titans/15m/15m2.tscn"),
		preload("res://scenes/titans/15m/15m3.tscn")
	],
	[ # 20m titans
		preload("res://scenes/titans/20m/20m1.tscn"),
		preload("res://scenes/titans/20m/20m2.tscn"),
		preload("res://scenes/titans/20m/20m3.tscn")
	]
];

#onready var _titan_res: Resource = preload("res://scenes/titans/20m/20m3.tscn");

var spawn_positions: Array = [];
var titan_target_positions: Array = [];
var titan_pool: Array = [];
var titans_in_target_area: int = 0;

var target_health: float = MAX_TARGET_HEALTH;


func _ready() -> void:
	_garbage = GameEvents.connect("enemy_killed", self, "_on_enemy_killed");
	
	randomize();
	
	var height_indx: int = randi() % _titans_res.size();
	var titan_indx: int = randi() % _titans_res[height_indx].size();
	titan_pool.append([_titans_res[height_indx][titan_indx].instance(), height_indx]);
	self.add_child(titan_pool[0][0]);
	titan_pool[0][0].global_transform.origin = Vector3(1000, 1000, 1000);
	
	for spawn_pos in _spawn_positions_container.get_children():
		spawn_positions.append(spawn_pos.global_transform.origin);
	
	for target_pos in _titan_targets_paths:
		titan_target_positions.append(self.get_tree().get_nodes_in_group("target")[0].global_transform.origin);


func _on_SpawnTitan_timeout() -> void:
	var spawn_pos: Vector3 = spawn_positions[randi() % spawn_positions.size()];
	
	var target_pos: Vector3;
	if(titan_target_positions.size() > 1):
		target_pos = titan_target_positions[randi() % titan_target_positions.size()];
	else:
		target_pos = titan_target_positions[0];
	
	var titan_instance: Object;
	var height_indx: int;
	if(titan_pool.size() == 0):
		var titan_spawner: Array = spawn_titan();
		titan_instance = titan_spawner[0];
		height_indx = titan_spawner[1];
	else:
		var titan_spawner: Array = titan_pool[titan_pool.size() - 1];
		titan_instance = titan_spawner[0];
		height_indx = titan_spawner[1];
		titan_pool.remove(titan_pool.find(titan_spawner));
	
	titan_instance.nav_mesh = _navmeshes[height_indx];
	titan_instance.global_transform.origin = spawn_pos;
	titan_instance.target_pos = target_pos;
	titan_instance.init_pathfinding();
	
	GameEvents.emit_enemy_spawned_signal(titan_instance);


func spawn_titan() -> Array:
	randomize();
	var height_indx: int = randi() % _titans_res.size();
	var titan_indx: int = randi() % _titans_res[height_indx].size();
	var titan_instance: Object = _titans_res[height_indx][titan_indx].instance();
	self.add_child(titan_instance);
	return [titan_instance, height_indx];


func _on_enemy_killed(enemy):
	self.remove_child(enemy);
