extends Control

var _garbage;

export(NodePath) onready var map_rect = get_node(map_rect) as ColorRect;
export(Vector2) var map_size;

var targets: Array = [];
var enemies: Array = [];
var player: Object;


func calculate_relative_position(world_pos: Vector3) -> Vector2:
	return Vector2(
		-(world_pos.x + (map_size.x / 2.0)) / map_size.x * map_rect.rect_size.x,
		(world_pos.z + (map_size.y / 2.0)) / map_size.y * map_rect.rect_size.y
	);


func _ready() -> void:
	_garbage = GameEvents.connect("enemy_spawned", self, "_on_enemy_spawned");
	
	for target in get_tree().get_nodes_in_group("target"):
		targets.append(target);
	
	player = get_tree().get_nodes_in_group("player")[0];


func _draw() -> void:
	draw_circle(calculate_relative_position(player.global_transform.origin), 3.0, Color.white);
	
	for enemy in enemies:
		if(enemy):
			draw_circle(calculate_relative_position(enemy.global_transform.origin), 3.0, Color.red);
		else:
			enemies.remove(enemies.find(enemy));
	
	for target in targets:
		draw_circle(calculate_relative_position(target.global_transform.origin), 3.0, Color.green);


func _process(_delta) -> void:
	update();


func _on_enemy_spawned(enemy: Object) -> void:
	enemies.append(enemy);
