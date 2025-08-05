@tool
class_name Door extends Node2D

static var _last_door_walked: Door
static var _last_door_mirrored : Door

static var _last_synced_doors : Array[Door]

static var _all_doors : Array[Door]

@export var room_type := Room.RoomTypes.None

@onready var area_player_average: Area2D = %Area_PlayerAverage
@onready var area_2d_close_door_inside: Area2D = %Area2D_close_door_inside
@onready var area_2d_close_door_outside: Area2D = %Area2D_close_door_outside
@onready var area_2d_sleep_helper: Area2D = %Area2D_sleep_helper

var parent_room : Room
var _temp_partner_door: Door

var _is_asleep := false: set = set_is_asleep
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
	##TODO: snap to the 16*16 grid
	_all_doors.append(self)
	area_player_average.body_entered.connect(_on_body_change.bind(true, area_player_average ))
	area_player_average.body_exited.connect(_on_body_change.bind(false, area_player_average))
	area_2d_close_door_inside.body_entered.connect(_on_body_change.bind(true,area_2d_close_door_inside ))
	area_2d_close_door_inside.body_exited.connect(_on_body_change.bind(false, area_2d_close_door_inside))
	area_2d_close_door_outside.body_entered.connect(_on_body_change.bind(true, area_2d_close_door_outside))
	area_2d_close_door_outside.body_exited.connect(_on_body_change.bind(false, area_2d_close_door_outside))
	area_2d_sleep_helper.body_exited.connect(_on_area_2d_sleep_helper_body_exited)

func _draw() -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-4, 16), Vector2(4, 16),
			Vector2(4, -16), Vector2(-4, -16)  ] 
			),
		[Color.WHITE]
	)
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2.from_angle( 0 * (PI/2.0) )*32, Color.WHEAT, 3.0)

func _on_area_entered(_area: Area2D) -> void:
	_open_door()

func sync_with(partner: Door) -> void:
	_last_synced_doors = [self, partner]
	_temp_partner_door = partner
	parent_room.summon(partner, self)
	set_is_asleep(true)

func _open_door() -> void:
	if !_last_synced_doors.has(self) or _temp_partner_door == null:
		_temp_partner_door = _find_temp_match_door()
	_temp_partner_door.sync_with(self)
	_is_open = true
	set_modulate(Color.ORANGE_RED)

func _close_door() -> void:
	_is_open = false
	set_visible(true)
	set_modulate(Color.WHITE)
	# which room do we activate or deactivate? 

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
	if _is_asleep:
		return
	#print_debug(self, " | _is_open: ", _is_open, "_player_found: ", _player_found, " | _player_inside: ", _player_inside, " | _player_outside: ", _player_outside)
	if _player_found and !_is_open:
		_open_door()
	elif !_player_found and _is_open:
		if _player_inside and _player_outside:
			# player is in the middle of the door, no action needed yet
			pass
		elif _player_inside: # keep current room
			_close_door()
			_temp_partner_door.parent_room.deactivate(false)
		elif _player_outside:
			_close_door()
			parent_room.deactivate(false)

func _find_temp_match_door() -> Door: # going to have a real match door at some point - the room the door is SUPPOsed to lead to 
	var posible_doors = _all_doors.duplicate()
	posible_doors = posible_doors.filter(__door_match_filter)
	return posible_doors.pick_random()

func __door_match_filter(potental_door: Door) -> bool:
	if potental_door.parent_room == parent_room: # no looping into self
		return false
	if potental_door.parent_room.room_type != room_type:  # door is for the wrong kind of room
		return false
	if potental_door.room_type != parent_room.room_type:
		return false # door could not lead back here
	return true

func _on_area_2d_sleep_helper_body_exited(body: Node2D) -> void:
	if body is Player:
		if _is_asleep:
			set_is_asleep(false)

func set_is_asleep(is_asleep: bool) -> void:
	if _is_asleep != is_asleep:
		_is_asleep = is_asleep
		area_2d_sleep_helper.set_visible(_is_asleep)
