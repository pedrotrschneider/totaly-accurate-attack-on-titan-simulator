extends VBoxContainer

export(NodePath) onready var time_label = get_node(time_label) as Label;
export(NodePath) onready var titans_killed_label = get_node(titans_killed_label) as Label;

onready var level: Object = self.get_parent().get_parent();


func _ready():
	pass


func _process(_delta) -> void:
	time_label.text = "Time: " + str(stepify(level.total_time_ellapsed, 0.1));
	titans_killed_label.text = "Titans killed: " + str(level.titans_killed);
