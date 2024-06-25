extends Node3D

const SPAWN_RANDOM := 5.0

func _ready():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected_disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	
func add_player(id: int):
	var character = preload("res://Scenes/player.tscn").instantiate()
	character.player = id
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	$players.add_child(character, true)
	
func del_player(id: int):
	if not $players.has_node(str(id)):
		return
	
	$players.get_node(str(id)).queue_free()
