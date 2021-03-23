extends CanvasLayer

var _garbage;

var scene_selected: bool = false;

func _ready():
	_garbage = GameEvents.connect("go_to_scene", self, "_on_go_to_scene");


func _on_go_to_scene(scene: PackedScene) -> void:
	if(!scene_selected):
		scene_selected = true;
		self.get_parent().add_child(scene.instance());
		self.call_deferred("free");
