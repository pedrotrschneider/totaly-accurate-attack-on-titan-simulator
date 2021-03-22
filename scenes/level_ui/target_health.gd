extends Control

var _garbage;

var health_bar_res: Resource = preload("res://scenes/health_bar/health_bar.tscn") as Resource;
var targets: Array = [];
var health_bars: Array = [];

func _ready():
	targets = get_tree().get_nodes_in_group("target");
	
	for target in targets:
		var health_bar_instance: Object = health_bar_res.instance();
		self.add_child(health_bar_instance);
		health_bars.append(health_bar_instance.get_child(1));

func _process(delta):
	for i in targets.size():
		var target: Position3D = targets[i];
		var health_bar: ColorRect = health_bars[i];
		
		health_bar.rect_scale.x = lerp(health_bar.rect_scale.x, target.health / target.MAX_HEALTH, delta * 5);
