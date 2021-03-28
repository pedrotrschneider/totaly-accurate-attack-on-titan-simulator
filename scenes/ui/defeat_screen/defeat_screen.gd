extends CanvasLayer

var _garbage;

export(NodePath) onready var animation_player = get_node(animation_player) as AnimationPlayer;
export(NodePath) onready var time_label = get_node(time_label) as Label;
export(NodePath) onready var titans_killed_label = get_node(titans_killed_label) as Label;

var game_over: bool = false;
var level: Object;

func _ready():
	level = self.get_tree().get_nodes_in_group("level")[0];
	
	time_label.text = "Time: " + str(stepify(level.total_time_ellapsed, 0.1));
	titans_killed_label.text = "Titans killed: " + str(level.titans_killed);
	
	animation_player.play("defeated");
	yield(animation_player, "animation_finished");
	game_over = true


func _input(event):
	if(game_over):
		if(event is InputEventMouseButton || event is InputEventKey):
			if(event.is_pressed()):
				GameEvents.emit_main_menu_selected_signal();
