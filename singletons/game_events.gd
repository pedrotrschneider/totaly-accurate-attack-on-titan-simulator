extends Node


# Game controll events
signal main_menu_selected;
signal arcade_mode_selected;
signal tutorial_selected;
signal resume_selected;
signal pause;
signal unpause;
signal quit_selected;
signal game_over;

# Audio signals
signal play_main_menu_bg;
signal play_arcade_bg;
signal play_tutorial_bg;

# Player signals
signal attack;
signal respawn_player(position);

# Enemy signals
signal enemy_killed(object);
signal enemy_spawned(enemy);


func emit_main_menu_selected_signal() -> void:
	self.emit_signal("main_menu_selected");


func emit_arcade_mode_selected_signal() -> void:
	self.emit_signal("arcade_mode_selected");


func emit_tutorial_selected_signal() -> void:
	self.emit_signal("tutorial_selected");


func emit_resume_selected_signal() -> void:
	self.emit_signal("resume_selected");


func emit_pause_signal() -> void:
	self.emit_signal("pause");


func emit_unpause_signal() -> void:
	self.emit_signal("unpause");


func emit_quit_selected_signal() -> void:
	self.emit_signal("quit_selected");


func emit_game_over_signal() -> void:
	self.emit_signal("game_over");


func emit_play_main_menu_bg_signal() -> void:
	self.emit_signal("play_main_menu_bg");


func emit_play_arcade_bg_signal() -> void:
	self.emit_signal("play_arcade_bg");


func emit_play_tutorial_bg_signal() -> void:
	self.emit_signal("play_tutorial_bg");


func emit_attack_signal() -> void:
	self.emit_signal("attack");


func emit_respawn_player_signal(position: Vector3) -> void:
	self.emit_signal("respawn_player", position);


func emit_enemy_killed_signal(object: Object) -> void:
	self.emit_signal("enemy_killed", object);


func emit_enemy_spawned_signal(enemy: Object) -> void:
	self.emit_signal("enemy_spawned", enemy);
