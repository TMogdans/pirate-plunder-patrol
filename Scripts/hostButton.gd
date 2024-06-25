extends Button


func _on_pressed():
	print_debug("host clicked")
	EventBus.emit_signal("host_button_clicked")
