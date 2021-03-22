extends Spatial

var _garbage;

export(NodePath) onready var _animation_player = get_node(_animation_player) as AnimationPlayer;

var anim_speed: float = 4.0;

func _ready() -> void:
	_garbage = GameEvents.connect("attack", self, "_on_attack");
	
	_animation_player.playback_speed = anim_speed;

func _on_attack() -> void:
	_animation_player.play("AttackGo2");
