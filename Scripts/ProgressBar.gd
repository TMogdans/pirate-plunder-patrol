extends TextureProgressBar

var bar_red = preload("res://Assets/Sprites/barHorizontal_red_mid 200.png")
var bar_green = preload("res://Assets/Sprites/barHorizontal_green_mid 200.png")
var bar_yellow = preload("res://Assets/Sprites/barHorizontal_yellow_mid 200.png")

func _ready():
	hide()
	
func update_progress(_value, _max_value):
	value = _value
	if value > 0:
		show()
		texture_progress = bar_red
	if value > 0.45:
		texture_progress = bar_yellow
	if value > 0.75:
		texture_progress = bar_green
