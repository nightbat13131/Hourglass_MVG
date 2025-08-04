@tool
class_name Door extends Area2D

static var _last_door: Door
@export var room_type := Room.RoomTypes.None

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _draw() -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-4, 16), Vector2(4, 16),
			Vector2(4, -16), Vector2(-4, -16)  ] 
			),
		[Color.LIGHT_CORAL]
	)
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2.RIGHT*16, Color.WHEAT, 3.0)

func _on_area_entered(area: Area2D) -> void:
	if _last_door == self:
		return
	Room.get_room(room_type).activate(global_position, global_rotation)
	_last_door = self
