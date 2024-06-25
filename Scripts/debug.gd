extends PanelContainer

@onready var settings = LabelSettings.new()

func _ready():
	settings.font_size = 10

func _process(_delta):
	if visible:
		pass
		
func add_property(title: String, value, order: int) -> void:
	var target
	target = $MarginContainer/VBoxContainer.find_child(title, true, false)
	if !target:
		target = Label.new()
		target.label_settings = settings
		$MarginContainer/VBoxContainer.add_child(target)
		target.name = title
		target.text = title + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		$MarginContainer/VBoxContainer.move_child(target, order)