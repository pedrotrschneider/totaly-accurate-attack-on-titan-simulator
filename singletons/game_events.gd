extends Node


# Game controll events
signal main_menu_selected;
signal arcade_mode_selected;
signal quit_selected;
signal game_over;

# Player signals
signal attack;

# Enemy signals
signal enemy_killed(object);
signal enemy_spawned(enemy);

# UI events
signal go_to_scene(scene);


func emit_main_menu_selected_signal() -> void:
	self.emit_signal("main_menu_selected");


func emit_arcade_mode_selected_signal() -> void:
	self.emit_signal("arcade_mode_selected");


func emit_quit_selected_signal() -> void:
	self.emit_signal("quit_selected");


func emit_game_over_signal() -> void:
	self.emit_signal("game_over");


func emit_attack_signal() -> void:
	self.emit_signal("attack");


func emit_enemy_killed_signal(object: Object) -> void:
	self.emit_signal("enemy_killed", object);


func emit_enemy_spawned_signal(enemy: Object) -> void:
	self.emit_signal("enemy_spawned", enemy);


func emit_go_to_scene_signal(scene: PackedScene) -> void:
	self.emit_signal("go_to_scene", scene);
