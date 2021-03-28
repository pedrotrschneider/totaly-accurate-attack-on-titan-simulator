extends Spatial

var _garbage;

export(PackedScene) onready var audio_mananger_res;
export(PackedScene) onready var main_menu_scene_res;
export(PackedScene) onready var arcade_mode_res;
export(PackedScene) onready var tutorial_mode_res;
export(PackedScene) onready var pause_menu_res;
export(PackedScene) onready var defeat_scene_res;
export(PackedScene) onready var fps_meter_res;

var main_menu: Object;
var arcade_mode: Object;
var tutorial_mode: Object;
var pause_menu: Object;
var defeat_screen: Object;


func clear_children() -> void:
	for child in self.get_children():
		child.call_deferred("free");


func _ready() -> void:
	_garbage = GameEvents.connect("main_menu_selected", self, "_on_main_menu_selected");
	_garbage = GameEvents.connect("arcade_mode_selected", self, "_on_arcade_mode_selected");
	_garbage = GameEvents.connect("tutorial_selected", self, "_on_tutorial_selected");
	_garbage = GameEvents.connect("resume_selected", self, "_on_resume_selected");
	_garbage = GameEvents.connect("quit_selected", self, "_on_quit_selected");
	_garbage = GameEvents.connect("game_over", self, "_on_game_over");
	
	main_menu = main_menu_scene_res.instance()
	self.add_child(main_menu);
	self.get_parent().call_deferred("add_child", fps_meter_res.instance());
	self.get_parent().call_deferred("add_child", audio_mananger_res.instance());
	
	yield(self.get_tree().create_timer(0.5), "timeout");
	GameEvents.emit_play_main_menu_bg_signal();


func _process(_delta) -> void:
	if(tutorial_mode || arcade_mode):
		if (Input.is_action_just_pressed("ui_cancel")):
			if(!pause_menu):
				pause();
			else:
				_on_resume_selected();

func pause() -> void:
	Engine.time_scale = 0.0;
	GameEvents.emit_pause_signal();
	Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
	pause_menu = pause_menu_res.instance();
	self.add_child(pause_menu);


func _on_main_menu_selected() -> void:
	GameEvents.emit_play_main_menu_bg_signal();
	Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
	clear_children();
	main_menu = main_menu_scene_res.instance();
	self.add_child(main_menu);


func _on_arcade_mode_selected() -> void:
	GameEvents.emit_play_arcade_bg_signal();
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	clear_children();
	arcade_mode = arcade_mode_res.instance();
	self.add_child(arcade_mode);


func _on_tutorial_selected() -> void:
	GameEvents.emit_play_tutorial_bg_signal();
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	clear_children();
	tutorial_mode = tutorial_mode_res.instance();
	self.add_child(tutorial_mode);


func _on_resume_selected() -> void:
	Engine.time_scale = 1.0;
	GameEvents.emit_unpause_signal();
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if(pause_menu):
		pause_menu.call_deferred("free");


func _on_quit_selected() -> void:
	self.get_tree().call_deferred("quit");


func _on_game_over() -> void:
	Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
	if(arcade_mode):
		arcade_mode.call_deferred("free");
	defeat_screen = defeat_scene_res.instance();
	self.add_child(defeat_screen);
	
