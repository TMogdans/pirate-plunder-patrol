extends MultiplayerSynchronizer

@export var direction := Vector2()

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
