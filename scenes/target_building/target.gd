extends Position3D

export(float) var MAX_HEALTH = 100.0;

var health: float = MAX_HEALTH;
var dead: bool = false;

func _ready():
	pass


func _on_TargetArea_body_entered(body) -> void:
	if(body.is_in_group("enemy")):
		body.got_to_target();
		body.connect("attack_target", self, "_on_attack_target");


func _on_TargetArea_body_exited(body) -> void:
	if(body.is_in_group("enemy")):
		body.disconnect("attack_target", self, "_on_attack_target");


func _on_attack_target(damage: float):
	health -= damage;
	
	if(health <= 0 && !dead):
		dead = true;
		GameEvents.emit_signal("game_over", self.get_parent());
