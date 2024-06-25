extends interactable

var amount = 99

@export var type: Stocks.TYPES

func interact():
	print_debug("here, you get")
	if amount > 0:
		amount -= 1
		
		return type
