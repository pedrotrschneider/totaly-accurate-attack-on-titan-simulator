extends CanvasLayer

var _garbage;

export(NodePath) onready var resume_button = get_node(resume_button) as Button;
export(NodePath) onready var quit_to_main_menu_button = get_node(quit_to_main_menu_button) as Button;
export(NodePath) onready var quit_button = get_node(quit_button) as Button;

func _ready():
	_garbage = resume_button.connect("pressed", self, "_on_resume_selected");
	_garbage = quit_to_main_menu_button.connect("pressed", self, "_on_main_menu_selected");
	_garbage = quit_button.connect("pressed", self, "_on_quit_selected");


func _on_resume_selected() -> void:
	GameEvents.emit_resume_selected_signal();


func _on_main_menu_selected() -> void:
	GameEvents.emit_main_menu_selected_signal();
	self.call_deferred("free");


func _on_quit_selected() -> void:
	GameEvents.emit_quit_selected_signal();
