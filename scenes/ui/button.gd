extends Label

var _garbage;

export(bool) var selectable = true;

onready var button: Button = self.get_children()[0] as Button;
onready var font: Font = self.get_font("font");
var mouse_over: bool = false;


func _ready():
	if(selectable):
		_garbage = button.connect("mouse_entered", self, "_on_mouse_entered");
		_garbage = button.connect("mouse_exited", self, "_on_mouse_exited");
	
	font.outline_color = Color(1.0, 1.0, 1.0, 0.0);


func _process(_delta):
	if(mouse_over):
		font.outline_color = lerp(font.outline_color, Color.black, 0.1);
	else:
		font.outline_color = lerp(font.outline_color, Color(1.0, 1.0, 1.0, 0.0), 0.1);


func _on_mouse_entered():
	mouse_over = true;


func _on_mouse_exited():
	mouse_over = false;
