extends VBoxContainer

export(NodePath) onready var bullet_time_rect = get_node(bullet_time_rect) as ColorRect;

onready var player: RigidBody = self.get_tree().get_nodes_in_group("player")[0];

func _ready():
	pass


func _process(delta):
	bullet_time_rect.rect_scale.x = player.bullet_time_stamina / player.MAX_BULLET_TIME_STAMINA;
