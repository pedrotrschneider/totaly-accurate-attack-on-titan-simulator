extends Area

var _garbage;

export(NodePath) onready var label = get_node(label) as Label;
export(NodePath) onready var color_rect = get_node(color_rect) as ColorRect;
export(String) var text = "";


func _ready() -> void:
	_garbage = self.connect("body_entered", self, "_on_player_entered");
	_garbage = self.connect("body_exited", self, "_on_player_exited");
	
	label.text = text;
	color_rect.hide();


func _on_player_entered(_body: Node) -> void:
	color_rect.show();


func _on_player_exited(_body: Node) -> void:
	color_rect.hide();
