@tool
class_name Door extends Node2D

static var _last_door_walked: Door
static var _last_door_mirrored : Door
@export var room_type := Room.RoomTypes.None

@onready var area_player_average: Area2D = %Area_PlayerAverage
@onready var area_2d_close_door_inside: Area2D = %Area2D_close_door_inside
@onready var area_2d_close_door_outside: Area2D = %Area2D_close_door_outside

var parent_room : Room
var child_room : Room

var _player_found := false
var _player_inside := false
var _player_outside := false

var _is_open := false

# when the player leaves...
# notfound, inside, not_outside, 
## close and keep current room
# notfound, notinside, outside, 
## close and hide current room
# notfound, inside, outside, 
## wait untill one of the sides are "not

func _ready() -> void:
	area_player_average.body_entered.connect(_on_body_change.bind(true, area_player_average ))
	area_player_average.body_exited.connect(_on_body_change.bind(false, area_player_average))
	area_2d_close_door_inside.body_entered.connect(_on_body_change.bind(true,area_2d_close_door_inside ))
	area_2d_close_door_inside.body_exited.connect(_on_body_change.bind(false, area_2d_close_door_inside))
	area_2d_close_door_outside.body_entered.connect(_on_body_change.bind(true, area_2d_close_door_outside))
	area_2d_close_door_outside.body_exited.connect(_on_body_change.bind(false, area_2d_close_door_outside))

func _draw() -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-4, 16), Vector2(4, 16),
			Vector2(4, -16), Vector2(-4, -16)  ] 
			),
		[Color.LIGHT_CORAL]
	)
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2.RIGHT*32, Color.WHEAT, 3.0)

func _on_area_entered(_area: Area2D) -> void:
	_open_door()

func _open_door() -> void: 
	if _last_door_walked == self:
		child_room.activate(global_position, global_rotation, false)
	else:
		child_room = Room.get_room(room_type, parent_room.room_type)
		child_room.activate(global_position, global_rotation, false)
		_last_door_walked = self
	
	_is_open = true
	set_visible(false)

func _close_door(is_inside) -> void:
	_is_open = false
	set_visible(true)
	if child_room and !is_inside:
		child_room.deactivate(false)

func _on_body_change(body: Node2D, is_entering: bool, area: Area2D) -> void:
	if !body is Player:
		return
	match area:
		area_player_average:
			_player_found = is_entering
		area_2d_close_door_inside:
			_player_inside = is_entering
		area_2d_close_door_outside:
			_player_outside = is_entering
		_:
			printerr("Door._on_body_change area: ", area)
	
	if !_is_open and _player_found:
		_open_door()
	elif _is_open and !_player_found:
		
		_close_door(_player_inside)
