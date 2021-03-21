extends KinematicBody

export(NodePath) onready var _skeleton = get_node(_skeleton) as Skeleton;
export(NodePath) onready var _anim_tree = get_node(_anim_tree) as AnimationTree;


func _ready():
	pass


func _physics_process(delta):
	var root_motion: Transform = _anim_tree.get_root_motion_transform();
	
	var velocity: Vector3 = (root_motion.origin / delta);
	velocity *= Vector3.FORWARD * pow(self.scale.x, 2) * pow(_skeleton.scale.x, 2);
	
	move_and_slide(velocity);
