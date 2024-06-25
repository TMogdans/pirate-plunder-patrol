extends CharacterBody3D

@export var max_speed: float = 8.0
@export var dash_speed: float = 16.0
@export var speed: float = 0.0
@export var acceleration: float = 16.0
@export var fall_acceleration: int = 75
@export var friction: float = 10.0
@export var player := 1:
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)

@onready var detector = $Pivot/RayCast3D
@onready var level = get_node("../level")
@onready var input = $PlayerInput

var direction = Vector3.ZERO
var target_velocity = Vector3.ZERO
var interaction_progress: float = 0
var interaction_speed: float = 1.0
var interaction_goal: float = 1.0
var interaction_lock: bool = false
var is_dashing: bool = false
var carry_pos: Vector3 = Vector3(0.0, 1.5, 0.0)

var inventory: Array[Item] = []
var inventory_capacity = 1

@onready var debug_panel = get_node("../UI/DebugPanel")

var item_map: Dictionary = {
	Stocks.TYPES.CANNONBALLS: preload("res://Scenes/cannonballs.tscn"),
	Stocks.TYPES.GUNPOWDER: preload("res://Scenes/powder.tscn"),
	Stocks.TYPES.WOOD: preload("res://Scenes/wood.tscn"),
	Stocks.TYPES.FIRST_AID: preload("res://Scenes/firstaid.tscn")
}

func _ready() -> void:
	if player == multiplayer.get_unique_id():
		$CameraPivot/Camera3D.current = true

func _process(_delta) -> void:
	pass

func _physics_process(delta) -> void:
	if input.is_action_pressed("interact"):
		if detector.is_colliding() and not interaction_lock:
			var collider = detector.get_collider()
			if collider.has_method("get_thing"):
				match collider.get_thing():
					Thing.THING.STORAGE when collider is interactable:
						interaction_progress += interaction_speed * delta
						
						if interaction_progress >= interaction_goal:
							interaction_lock = true
							var type = collider.interact()
							var instance = _create_item(type)
							_add_to_inventory(type, instance)
					Thing.THING.ITEM when collider is interactable:
						interaction_progress += interaction_speed * delta
						
						if interaction_progress >= interaction_goal:
							interaction_lock = true
							var type = collider.interact()
							collider.reparent(self)
							collider.is_carried = true
							collider.position = carry_pos
							collider.get_node("CollisionShape3D").disabled = true
							_add_to_inventory(type, collider)
					Thing.THING.CANNON when collider is interactable:
						if collider.has_powder() and collider.has_cannonball():
							interaction_progress += interaction_speed * delta
							if interaction_progress >= interaction_goal:
								interaction_lock = true
								collider.interact()
						elif not collider.has_powder() and _has_item(Stocks.TYPES.GUNPOWDER):
							interaction_progress += interaction_speed * delta
							if interaction_progress >= interaction_goal:
								interaction_lock = true
								collider.load_powder()
								_destroy_item(Stocks.TYPES.GUNPOWDER)
						elif not collider.has_cannonball() and _has_item(Stocks.TYPES.CANNONBALLS):
							interaction_progress += interaction_speed * delta
							if interaction_progress >= interaction_goal:
								interaction_lock = true
								collider.load_cannonball()
								_destroy_item(Stocks.TYPES.CANNONBALLS)
	
	if input.is_action_just_released("interact"):
		interaction_lock = false
		interaction_progress = 0.0
		
	if input.is_action_pressed("cancel"):
		if not inventory.is_empty():
			var item = _get_last_item_from_inventory()
			if item != null:
				item.get_instance().reparent(level)
				item.get_instance().is_carried = false
				item.get_instance().spawn()
			
	
	debug_panel.add_property("interaction progress", interaction_progress, 2)
	debug_panel.add_property("is_dashing", is_dashing, 3)
	
	if not is_dashing:
		if input.is_action_pressed("move_right"):
			direction.x += 1
			speed += acceleration * delta
		if input.is_action_pressed("move_left"):
			direction.x -= 1
			speed += acceleration * delta
		if input.is_action_pressed("move_back"):
			direction.z += 1
			speed += acceleration * delta
		if input.is_action_pressed("move_forward"):
			direction.z -= 1
			speed += acceleration * delta
		
		speed = clampf(speed, 0.0, max_speed)
	
	if speed <= max_speed:
		is_dashing = false
	
	if not is_dashing and input.is_action_pressed("dash"):
		speed = dash_speed
		is_dashing = true
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	
	speed -= friction * delta
	if speed < 0:
		speed = 0
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	debug_panel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
	debug_panel.add_property("speed", speed, 1)
	
	velocity = target_velocity	
	move_and_slide()

func _create_item(item: Stocks.TYPES) -> Stocks:
	var scene: Resource = item_map[item]
	var instance = scene.instantiate()
	
	instance.type = item
	instance.position = carry_pos
	add_child(instance)
	instance.get_node("CollisionShape3D").disabled = true
	return instance
	
func _destroy_item(item_id: Stocks.TYPES) -> void:
	if _has_item(item_id):
		var item = _get_item(item_id)
		_remove_from_inventory(item_id)
		var instance = item.get_instance()
		instance.queue_free()

func _add_to_inventory(item: Stocks.TYPES, instance: Stocks):
	if inventory.size() < inventory_capacity:
		inventory.append(Item.new(item, instance))
		
	print_debug("inventory: ", inventory)

func _get_last_item_from_inventory():
	if not inventory.is_empty():
		return inventory.pop_back()

func _has_item(item_id: Stocks.TYPES) -> bool:
	for item in inventory:
		if item.get_id() == item_id:
			return true
	return false

func _get_item(item_id: Stocks.TYPES):
	for item in inventory:
		if item.get_id() == item_id:
			return item

func _remove_from_inventory(id: Stocks.TYPES) -> void:
	var index = null
	for i in range(inventory.size()):
		if inventory[i].get_id() == id:
			index = i
			break
	
	inventory.remove_at(index)
