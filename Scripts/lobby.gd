extends Node

const PORT = 4422

func _ready():
	EventBus.host_button_clicked.connect(_on_host_pressed)
	EventBus.connect_button_clicked.connect(_on_connect_pressed)
	get_tree().paused = true
	#multiplayer.server_relay = false
	
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()

func _on_host_pressed():
	print_debug("start as server")
	# start as server
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	
	if error: print("ERROR CODE: ", error)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	
func _on_connect_pressed():
	print_debug("start as client")
	# start as client
	var txt: String = $UI/LobbyUI/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	
func start_game():
	$UI/LobbyUI.hide()
	get_tree().paused = false
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Scenes/pirate_ship_01.tscn"))

func change_level(scene: PackedScene):
	var level = $world/level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
		
	level.add_child(scene.instantiate())

func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level.call_deferred(load("res://Scenes/pirate_ship_01.tscn"))

