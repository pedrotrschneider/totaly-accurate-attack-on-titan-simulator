extends Area

var _grabage;

var enemy_hitbox_flag;

signal hit;


func _ready() -> void:
	_grabage = self.connect("area_entered", self, "_on_area_entered");


func _on_area_entered(area) -> void:
	if("sword_hitbox_flag" in area):
		self.emit_signal("hit");
