extends Node

var _garbage;

export(NodePath) onready var arcade_bg_player = get_node(arcade_bg_player) as AudioStreamPlayer;
export(NodePath) onready var main_menu_bg_player = get_node(main_menu_bg_player) as AudioStreamPlayer;
export(NodePath) onready var tutorial_bg_player = get_node(tutorial_bg_player) as AudioStreamPlayer;


func stop_all() -> void:
	main_menu_bg_player.stop();
	arcade_bg_player.stop();
	tutorial_bg_player.stop();


func _ready():
	_garbage = GameEvents.connect("play_main_menu_bg", self, "_on_play_main_menu_bg");
	_garbage = GameEvents.connect("play_arcade_bg", self, "_on_play_arcade_bg");
	_garbage = GameEvents.connect("play_tutorial_bg", self, "_on_play_tutorial_bg");


func _on_play_main_menu_bg() -> void:
	print("hi")
	stop_all();
	main_menu_bg_player.play();


func _on_play_arcade_bg() -> void:
	stop_all();
	arcade_bg_player.play();


func _on_play_tutorial_bg() -> void:
	stop_all();
	tutorial_bg_player.play();
