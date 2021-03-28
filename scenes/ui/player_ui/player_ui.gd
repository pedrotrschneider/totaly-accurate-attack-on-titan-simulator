extends CanvasLayer

export(NodePath) onready var hook_1_ui = get_node(hook_1_ui) as ColorRect;
export(NodePath) onready var hook_2_ui = get_node(hook_2_ui) as ColorRect;
export(NodePath) onready var bullet_time_rect = get_node(bullet_time_rect) as ColorRect;
export(NodePath) onready var gas_rect = get_node(gas_rect) as ColorRect;


onready var player: RigidBody = self.get_tree().get_nodes_in_group("player")[0];

func _ready():
	pass


func _process(delta):
	hook_1_ui.visible = player.hook_1 != 0;
	hook_2_ui.visible = player.hook_2 != 0;
	
	bullet_time_rect.rect_scale.x = player.bullet_time_stamina / player.MAX_BULLET_TIME_STAMINA;
	gas_rect.rect_scale.x = lerp(gas_rect.rect_scale.x, player.gas_amount / player.MAX_GAS_AMOUNT, delta * 10);
