extends interactable

var _has_powder: bool = false
var _has_cannonball: bool = false

func interact():
	if has_powder and has_cannonball:
		_fire_cannon()

func has_powder() -> bool:
	return _has_powder

func has_cannonball() -> bool:
	return _has_cannonball

func load_powder() -> void:
	print_debug("got powder")
	_has_powder = true

func load_cannonball() -> void:
	print_debug("got cannonball")
	_has_cannonball = true

func _fire_cannon() -> void:
	print_debug("fire cannon")
	_has_cannonball = false
	_has_powder = false
	pass
