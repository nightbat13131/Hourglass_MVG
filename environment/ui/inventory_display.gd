class_name Inventory extends HBoxContainer

static var inventory : Array[PackedScene]

static var _current : Inventory

func _ready() -> void:
	_current = self

static func pickup_item(thing: PackedScene) -> void:
	print_debug(inventory)
	var real_thing = thing.instantiate()
	if !real_thing is InventoryItem:
		printerr("NON InventoryItem passed to inventory ", real_thing)
		return
	if inventory.has(thing):
		printerr("Player already has ", thing)
		return
	inventory.append(thing)
	_current.add_child(real_thing)
	print_debug(inventory)

static func check_inventory(thing: PackedScene) -> bool:
	print_debug(inventory)
	return inventory.has(thing)
