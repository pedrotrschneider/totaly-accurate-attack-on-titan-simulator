extends Spatial

var _garbage;

export(PackedScene) onready var main_menu_scene_res;
export(PackedScene) onready var arcade_mode_res;
export(PackedScene) onready var defeat_scene_res;
export(PackedScene) onready var fps_meter_res;

var main_menu: Object;
var arcade_mode: Object;
var defeat_screen: Object;
var fps_meter: Object;


func _ready():
	_garbage = GameEvents.connect("main_menu_selected", self, "_on_main_menu_selected");
	_garbage = GameEvents.connect("arcade_mode_selected", self, "_on_arcade_mode_selected");
	_garbage = GameEvents.connect("quit_selected", self, "_on_quit_selected");
	_garbage = GameEvents.connect("game_over", self, "_on_game_over");
	
	main_menu = main_menu_scene_res.instance()
	fps_meter = fps_meter_res.instance();
	self.add_child(main_menu);
	self.add_child(fps_meter);


func _on_main_menu_selected() -> void:
	if(defeat_screen):
		defeat_screen.call_deferred("free");
	main_menu = main_menu_scene_res.instance();
	self.add_child(main_menu);


func _on_arcade_mode_selected() -> void:
	if(main_menu):
		main_menu.call_deferred("free");
	arcade_mode = arcade_mode_res.instance();
	self.add_child(arcade_mode);


func _on_quit_selected() -> void:
	self.get_tree().call_deferred("quit");


func _on_game_over() -> void:
	if(arcade_mode):
		arcade_mode.call_deferred("free");
	defeat_screen = defeat_scene_res.instance();
	self.add_child(defeat_screen);
	
