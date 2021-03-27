extends CanvasLayer

var _garbage;

export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer;

var game_over: bool = false;

func _ready():
	Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
	animation_player.play("defeated");
	yield(animation_player, "animation_finished");
	game_over = true


func _input(event):
	if(game_over):
		if(event is InputEventMouseButton || event is InputEventKey):
			if(event.is_pressed()):
				GameEvents.emit_main_menu_selected_signal();
