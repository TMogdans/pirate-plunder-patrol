class_name Item
extends Node

var _id: int
var _instance: Node

func _init(id: int, instance: Node) -> void:
	_id = id
	_instance = instance

func get_id() -> int:
	return _id

func get_instance() -> Node:
	return _instance
