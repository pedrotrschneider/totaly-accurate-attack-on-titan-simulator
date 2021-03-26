extends Control

var _garbage;

export(NodePath) onready var map_rect = get_node(map_rect) as ColorRect;
export(Vector2) var map_size;

onready var _player_minimap_texture: Texture = preload("res://resources/assets/textures/player_minimap_icon.png") as Texture;

var targets: Array = [];
var enemies: Array = [];
var player: Object;


func calculate_relative_position(world_pos: Vector3) -> Vector2:
	return Vector2(
		(world_pos.x + (map_size.x / 2.0)) / map_size.x * map_rect.rect_size.x,
		(world_pos.z + (map_size.y / 2.0)) / map_size.y * map_rect.rect_size.y
	);


func _ready() -> void:
	_garbage = GameEvents.connect("enemy_spawned", self, "_on_enemy_spawned");
	_garbage = GameEvents.connect("enemy_killed", self, "_on_enemy_killed");
	
	for target in get_tree().get_nodes_in_group("target"):
		targets.append(target);
	
	player = get_tree().get_nodes_in_group("player")[0];


func _draw() -> void:
	# Draw enemy markers
	for enemy in enemies:
		if(enemy.is_inside_tree()):
			var enemy_pos: Vector2 = calculate_relative_position(enemy.global_transform.origin);
			if(!(enemy_pos.x > map_rect.rect_size.x) && !(enemy_pos.y > map_rect.rect_size.y)):
				draw_circle(calculate_relative_position(enemy.global_transform.origin), 3.0, Color.red);
		else:
			enemies.remove(enemies.find(enemy));
	 # Draw target markers
	for target in targets:
		draw_circle(calculate_relative_position(target.global_transform.origin), 3.0, Color.green);
	
	# Draw player marker
	var p_rel_pos: Vector2 = calculate_relative_position(player.global_transform.origin);
	draw_circle(p_rel_pos, 3.0, Color.white);
	var angle: float = deg2rad(player.rotation_degrees.y);
	var p_rel_end_pos: Vector2 = p_rel_pos - Vector2(10 * sin(angle), 10 * cos(angle));
	draw_line(p_rel_pos, p_rel_end_pos, Color.white, 1.0);


func _process(_delta) -> void:
	update(); # Need this to call draw every frame


func _on_enemy_spawned(enemy: Object) -> void:
	enemies.append(enemy);


func _on_enemy_killed(enemy: Object) -> void:
	enemies.remove(enemies.find(enemy));
