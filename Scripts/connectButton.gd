extends Button

func _on_pressed():
	print_debug("connect clicked")
	EventBus.emit_signal("connect_button_clicked")
