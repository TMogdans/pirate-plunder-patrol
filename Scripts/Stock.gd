class_name Stocks
extends interactable

enum TYPES { CANNONBALLS, GUNPOWDER, WOOD, FIRST_AID }

var target_velocity = Vector3.ZERO
var gravity: float = -9.8
var is_carried = true
var speed: Vector3 = Vector3.ZERO
var friction: float = 5.0
var spawn_range: float = 0.5
var rnd = RandomNumberGenerator.new()
var type: TYPES

func _ready():
	thing = Thing.THING.ITEM

func spawn():
	speed = Vector3(rnd.randf_range(-spawn_range, spawn_range), spawn_range, rnd.randf_range(-spawn_range, spawn_range))
	$AnimationPlayer.play("float")

func _physics_process(delta):		
	if not is_carried:
		target_velocity.y = target_velocity.y + speed.y
		
		if speed.y > gravity:
			speed.y -= friction * delta
			
		if not is_on_floor():
			target_velocity.x = target_velocity.x + speed.x
			target_velocity.z = target_velocity.z + speed.z
			velocity = target_velocity
			
			move_and_slide()
	else:
		$CollisionShape3D.disabled = false

func get_thing() -> Thing.THING:
	return thing

func interact():
	print_debug("pick me up")
	return type
