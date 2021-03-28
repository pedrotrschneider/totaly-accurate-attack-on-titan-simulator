extends Spatial

var _garbage;

export(NodePath) onready var finish = get_node(finish) as Area;

func _ready() -> void:
	_garbage = finish.connect("body_entered", self, "_on_player_reach_finish_line");


func _on_player_reach_finish_line(body: Node) -> void:
	GameEvents.emit_main_menu_selected_signal();
