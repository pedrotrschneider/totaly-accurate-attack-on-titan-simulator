extends Node

# Player signals
signal attack;


func emit_attack_signal() -> void:
	emit_signal("attack");
