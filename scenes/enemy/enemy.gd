extends Spatial

var _garbage;

export(NodePath) onready var _hitbox = get_node(_hitbox) as Area;

var MAX_HIT_POINTS: int = 2;
var hit_points: int = 0;


func _ready():
	_garbage = _hitbox.connect("hit", self, "_on_hit");


func kill() -> void:
	print("I am now ded");
	hit_points = 0;


func _on_hit() -> void:
	print("I have been hit");
	hit_points += 1;
	if(hit_points >= MAX_HIT_POINTS):
		kill();
