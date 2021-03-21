extends Label


func _process(_delta):
	self.text = "fps: " + str(Engine.get_frames_per_second());
