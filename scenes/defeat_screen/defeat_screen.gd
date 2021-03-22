extends CanvasLayer

var _garbage;

export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer;
export(NodePath) onready var game_over_screen = get_node(game_over_screen) as Control;

var game_over: bool = false


func _ready():
	_garbage = GameEvents.connect("game_over", self, "_on_game_over");


func _input(event):
	if(game_over):
		if(event is InputEventMouseButton || event is InputEventKey):
			if(event.is_pressed()):
				print("Go back to main menu");


func _on_game_over(level: Object) -> void:
	if(!game_over):
		game_over = true;
		Input.set_mouse_mode((Input.MOUSE_MODE_VISIBLE));
		game_over_screen.show();
		animation_player.play("defeated");
		yield(animation_player, "animation_finished");
		level.call_deferred("queue_free");
