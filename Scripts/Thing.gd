class_name Thing
extends CharacterBody3D

enum THING { STORAGE, ITEM, CANNON }

@export var thing: THING

func get_thing() -> THING:
	return thing
