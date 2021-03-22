extends Control

var _garbage;

export(NodePath) onready var _health_rect = get_node(_health_rect) as ColorRect;

var max_health: float = 1;
var cur_health: float = 1;

func _ready():
	_garbage = GameEvents.connect("update_target_health", self, "_on_update_target_health");


func _process(delta):
	_health_rect.rect_scale.x = lerp(_health_rect.rect_scale.x, cur_health / max_health, delta * 5.0);


func _on_update_target_health(value: float, max_value: float):
	max_health = max_value;
	cur_health = value;
