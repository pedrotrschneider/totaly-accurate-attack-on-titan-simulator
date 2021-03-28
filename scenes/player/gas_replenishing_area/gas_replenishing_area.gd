extends Area

var _garbage;

var player: Object;
var player_on_area: bool = false;


func _ready():
	_garbage = self.connect("body_entered", self, "_on_player_entered");
	_garbage = self.connect("body_exited", self, "_on_player_exited");


func _process(delta):
	if(player_on_area && player):
		player.gas_amount += 100.0 * delta;


func _on_player_entered(body: Node) -> void:
	player_on_area = true;
	player = body;


func _on_player_exited(_body: Node) -> void:
	player_on_area = false;
