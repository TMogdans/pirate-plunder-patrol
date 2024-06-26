extends MultiplayerSynchronizer

@export var direction := Vector2()

@export var interacting := false
@export var dashing := false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func interact():
	interacting = true

@rpc("call_local")
func dash():
	dashing = true

func _process(_delta):
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Input.is_action_pressed("interact"):
		interact.rpc()
	if Input.is_action_just_pressed("dash"):
		dash.rpc()
