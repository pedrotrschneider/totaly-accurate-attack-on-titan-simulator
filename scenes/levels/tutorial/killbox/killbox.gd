extends Area

var _garbage;

export(NodePath) onready var respawn_pos = get_node(respawn_pos) as Position3D;


func _ready():
	_garbage = self.connect("body_entered", self, "_on_player_entered");


func _on_player_entered(_body: Node) -> void:
	GameEvents.emit_respawn_player_signal(respawn_pos.global_transform.origin);
