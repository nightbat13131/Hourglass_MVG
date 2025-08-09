class_name InteractionStates extends Resource

@export_multiline var _text : String
@export var _sprite_frame_cord := Vector2i(0,0)
@export var _sprite_color := Color.WHITE
@export var _highlight_color := Color.WHITE
## InventoryItem classed PackedScene

@export var _item_recive: PackedScene
@export var _item_give: PackedScene


func get_text() -> String: return _text

func get_sprite_color() -> Color: return _sprite_color

func get_sprite_frame_cord() -> Vector2i: return _sprite_frame_cord

func get_highlight_color() -> Color: return _highlight_color

func try_action() -> bool:
	if _item_give:
		Inventory.pickup_item(_item_give)
		return true
	elif _item_recive: 
		return Inventory.check_inventory(_item_recive)
	return true
