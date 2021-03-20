extends Position3D

var end_point:Position3D;

func _ready():
	pass

func _process(_delta):
	self.look_at(end_point.global_transform.origin, Vector3.UP);
	var dist_to_point:float = (self.global_transform.origin - end_point.global_transform.origin).length();
	self.scale.z = dist_to_point;
