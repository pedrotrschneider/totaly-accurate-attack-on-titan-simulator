extends Spatial

export(NodePath) onready var mesh = get_node(mesh) as MeshInstance;
export(NodePath) onready var hitbox = get_node(hitbox) as StaticBody;

var player: RigidBody;
var collision_shape: CollisionShape;


func _ready():
	player = self.get_tree().get_nodes_in_group("player")[0];
	collision_shape = hitbox.get_child(0);


func _process(delta):
	var dist_to_player = self.global_transform.origin.distance_to(player.global_transform.origin);
	
	if(dist_to_player > 60):
		if(mesh.visible):
			mesh.hide();
			collision_shape.disabled = true;
	else:
		if(!mesh.visible):
			mesh.show();
			collision_shape.disabled = false;
