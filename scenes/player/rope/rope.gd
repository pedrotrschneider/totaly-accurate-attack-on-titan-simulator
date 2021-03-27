extends Position3D

var end_point:Position3D;


func _process(_delta) -> void:
	if(end_point):
		self.look_at(end_point.global_transform.origin, Vector3.UP);
		var dist_to_point:float = (self.global_transform.origin - end_point.global_transform.origin).length();
		self.scale.z = dist_to_point;
