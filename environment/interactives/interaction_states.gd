class_name InteractionStates extends Resource

@export_multiline var _text : String
@export var _sprite_frame_cord := Vector2i(0,0)
@export var _sprite_color := Color.WHITE
@export var _highlight_color := Color.WHITE
## InventoryItem classed PackedScene

@export var _needs_item: PackedScene
@export var _gives_item: PackedScene


func get_text() -> String: return _text

func get_sprite_color() -> Color: return _sprite_color

func get_sprite_frame_cord() -> Vector2i: return _sprite_frame_cord

func get_highlight_color() -> Color: return _highlight_color

func try_action() -> bool:
	if _gives_item:
		Inventory.pickup_item(_gives_item)
		return true
	elif _needs_item: 
		return Inventory.check_inventory(_needs_item)
	return true
