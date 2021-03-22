extends Node

# Player signals
signal attack;

# Enemy signals
signal enemy_killed(object);

# UI events
signal enemy_spawned(enemy);


func emit_attack_signal() -> void:
	self.emit_signal("attack");


func emit_enemy_killed_signal(object: Object) -> void:
	self.emit_signal("enemy_killed", object);


func emit_enemy_spawned_signal(enemy: Object) -> void:
	self.emit_signal("enemy_spawned", enemy);
