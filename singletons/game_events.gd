extends Node

# Player signals
signal attack;

# Enemy signals
signal enemy_killed(object);


func emit_attack_signal() -> void:
	self.emit_signal("attack");


func emit_enemy_killed_signal(object) -> void:
	self.emit_signal("enemy_killed", object);
