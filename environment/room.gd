@tool
class_name Room extends TileMapLayer

enum RoomTypes {
	None = 0,
	Bedroom = 1, 
	Bathroom = 2, 
	Kitchen = 3,
	Garage = 9,
	Outside = 10,
	Hallway = 20,
}

static var room_list : Array[Room] = []
static var _last_room: Room

@export var room_type := RoomTypes.None

var alpha_tween : Tween
var ALPHA_DURATION := .30

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	deactivate(true)
	room_list.append(self)
	for each_child in get_children():
		if each_child is Door:
			each_child.parent_room = self

func activate(door_point: Vector2, door_angle: float, fast: bool) -> void:
	#print_debug(self, fast)
	set_global_position(door_point)
	set_rotation(door_angle-PI)
	var current_color = get_modulate()
	set_visible(true)
	if fast: 
		set_modulate( Color(Color.WHITE, 1.0) )
		set_process_mode(Node.PROCESS_MODE_INHERIT)
	else: 
		if alpha_tween != null: 
			if alpha_tween.is_valid():
				alpha_tween.kill()
		alpha_tween = get_tree().create_tween()
		alpha_tween.tween_method(set_modulate, current_color, Color(Color.WHITE, 1.0) , ALPHA_DURATION)

func deactivate(fast: bool) -> void:
	#print_debug(self, fast)
	var current_color = get_modulate()
	if fast:
		set_modulate( Color(Color.WHITE, 0.0) )
		set_visible(false)
		set_process_mode(Node.PROCESS_MODE_DISABLED)
	else: 
		if alpha_tween != null: 
			if alpha_tween.is_valid():
				alpha_tween.kill()
		alpha_tween = get_tree().create_tween()
		alpha_tween.tween_method(set_modulate, current_color, Color(Color.WHITE, 0.0) , ALPHA_DURATION)
		alpha_tween.tween_callback(set_process_mode.bind(Node.PROCESS_MODE_DISABLED))
		alpha_tween.tween_callback(set_visible.bind(false))

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2.RIGHT*32, Color.WHEAT, 3.0)

static func get_room(target_room_type: Room.RoomTypes, source_room_type: Room.RoomTypes) -> Room: # will eventually ask for a room type
	var next_room : Room
	var filtered_rooms = room_list.filter(_filter_room_type.bind(target_room_type))
	if filtered_rooms.size() == 0:
		printerr("Room.get_room filtered_rooms is empty. _room_type: ", target_room_type)
		return null
	next_room = filtered_rooms[0]
	if filtered_rooms.size() > 1:
		next_room = filtered_rooms.pick_random()
		while next_room == _last_room:
			next_room = filtered_rooms.pick_random()
		if _last_room:
			_last_room.deactivate(false)
		_last_room = next_room
	return next_room

static func _filter_room_type(room: Room, _room_type: RoomTypes) -> bool:
	if _room_type == RoomTypes.None:
		return true
	return room.room_type == _room_type
