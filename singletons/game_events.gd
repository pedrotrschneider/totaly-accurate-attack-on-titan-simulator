extends Node

# Player signals
signal attack;

# Enemy signals
signal enemy_killed(object);
signal damage_target(damage);

# UI events
signal update_target_health(value, max_value);
signal enemy_spawned(enemy);


func emit_attack_signal() -> void:
	self.emit_signal("attack");


func emit_enemy_killed_signal(object: Object) -> void:
	self.emit_signal("enemy_killed", object);


func emit_damage_target_signal(damage: float) -> void:
	self.emit_signal("damage_target", damage);


func emit_update_target_health_signal(value: float, max_value: float) -> void:
	self.emit_signal("update_target_health", value, max_value);


func emit_enemy_spawned_signal(enemy: Object) -> void:
	self.emit_signal("enemy_spawned", enemy);
