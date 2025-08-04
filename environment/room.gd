class_name Room extends TileMapLayer

enum RoomTypes {
	None = 0,
	Bedroom = 1, 
	Bathroom = 2, 
	Kitchen = 3,
}

static var room_list : Array[Room] = []
static var _last_room: Room

@export var room_type := RoomTypes.None

func _ready() -> void:
	deactivate()
	room_list.append(self)

func activate(door_point: Vector2, door_angle: float) -> void:
	set_global_position(door_point)
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	show()
	print_debug(self_modulate.a)
	self_modulate.a = 255
	set_rotation(door_angle-PI)

func deactivate() -> void:
	print_debug(self_modulate.a)
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	# hide()
	self_modulate.a = .1

static func get_room(room_type: Room.RoomTypes) -> Room: # will eventually ask for a room type
	
	var filtered_rooms = room_list.filter(_filter_room_type.bind(room_type))
	var next_room = filtered_rooms[0]
	if filtered_rooms.size() > 1:
		next_room = filtered_rooms.pick_random()
		while next_room == _last_room:
			next_room = filtered_rooms.pick_random()
		if _last_room:
			_last_room.deactivate()
		_last_room = next_room
	return next_room

static func _filter_room_type(room: Room, _room_type: RoomTypes) -> bool:
	if _room_type == RoomTypes.None:
		return true
	return room.room_type == _room_type
