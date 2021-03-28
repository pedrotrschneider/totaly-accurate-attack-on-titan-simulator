extends CanvasLayer

var _garbage;

export(NodePath) onready var arcade_mode_button = get_node(arcade_mode_button) as Button;
export(NodePath) onready var tutorial_button = get_node(tutorial_button) as Button;
export(NodePath) onready var quit_button = get_node(quit_button) as Button;


var scene_selected: bool = false;

func _ready() -> void:
	_garbage = arcade_mode_button.connect("pressed", self, "_on_arcade_mode_selected");
	_garbage = tutorial_button.connect("pressed", self, "_on_tutorial_selected");
	_garbage = quit_button.connect("pressed", self, "_on_quit_selected");


func _on_arcade_mode_selected() -> void:
	GameEvents.emit_arcade_mode_selected_signal();


func _on_tutorial_selected() -> void:
	GameEvents.emit_tutorial_selected_signal();


func _on_quit_selected() -> void:
	GameEvents.emit_quit_selected_signal();


func _on_go_to_scene(scene: PackedScene) -> void:
	if(!scene_selected):
		scene_selected = true;
		self.get_parent().add_child(scene.instance());
		self.call_deferred("free");
