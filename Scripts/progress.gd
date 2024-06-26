extends Sprite3D

func _ready():
	texture = $SubViewport.get_texture()

func update_progress(_value, _max_value):
	$SubViewport/ProgressBar.update_progress(_value, _max_value)
