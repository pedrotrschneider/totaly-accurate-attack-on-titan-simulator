extends Node

signal game_over(level);

# Player signals
signal attack;

# Enemy signals
signal enemy_killed(object);
signal enemy_spawned(enemy);


# UI events
signal go_to_scene(scene);

func emit_game_over_signal(level: Object) -> void:
	self.emit_signal("game_over", level);


func emit_attack_signal() -> void:
	self.emit_signal("attack");


func emit_enemy_killed_signal(object: Object) -> void:
	self.emit_signal("enemy_killed", object);


func emit_enemy_spawned_signal(enemy: Object) -> void:
	self.emit_signal("enemy_spawned", enemy);


func emit_go_to_scene_signal(scene: PackedScene) -> void:
	self.emit_signal("go_to_scene", scene);
