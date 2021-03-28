extends Spatial

var _garbage;

export(NodePath) onready var area = get_node(area) as Area;
export(NodePath) onready var anim_player = get_node(anim_player) as AnimationPlayer;
export(float) var playback_speed = 2;


func _ready():
	_garbage = area.connect("body_entered", self, "_on_player_entered");
	_garbage = area.connect("body_exited", self, "_on_player_exited");


func _on_player_entered(_body: Node) -> void:
	anim_player.play("Open", -1, playback_speed);


func _on_player_exited(_body: Node) -> void:
	anim_player.play("Close", -1, playback_speed);
