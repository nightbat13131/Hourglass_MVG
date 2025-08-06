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
var ALPHA_DURATION := .10

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	deactivate(true)
	room_list.append(self)
	for each_child in get_children():
		if each_child is Door:
			each_child.parent_room = self

func summon(summoning_door: Door, internal_door: Door) -> void:
	
	var target_qTAUs = (roundi(summoning_door.global_rotation/ (TAU/4.0))-2)%4
	var current_qTAUs = roundi(internal_door.global_rotation/ (TAU/4.0))%4
	if target_qTAUs != current_qTAUs: # not already correct
		set_global_rotation(0.0)
		current_qTAUs = roundi(internal_door.global_rotation/ (TAU/4.0))%4
		var parent_rotation = target_qTAUs - current_qTAUs
		set_global_rotation( (parent_rotation) * (TAU/4.0))
	
	var target_pos = summoning_door.global_position
	var target_offset = target_pos - internal_door.global_position
	if target_pos != target_offset: # not already correct
		set_global_position(target_pos)
		target_offset = target_pos - internal_door.global_position
		set_global_position(target_pos + target_offset)

	activate(target_pos, 0.0 ,  true)

func activate(door_point: Vector2, rotation_delta: float, fast: bool) -> void:
	var current_color = get_modulate()
	set_collision_enabled(true)
	set_visible(true)
	if fast: 
		set_modulate( Color(Color.WHITE, 1.0) )
		set_process_mode.bind(Node.PROCESS_MODE_INHERIT).call_deferred()
	else: 
		if alpha_tween != null: 
			if alpha_tween.is_valid():
				alpha_tween.kill()
		alpha_tween = get_tree().create_tween()
		alpha_tween.tween_method(set_modulate, current_color, Color(Color.WHITE, 1.0) , ALPHA_DURATION)

func deactivate(fast: bool) -> void:
	#print_debug(self, fast)
	var current_color = get_modulate()
	set_collision_enabled(false)
	for every_door in _get_doors():
		every_door.set_is_asleep(false)
	if fast:
		set_modulate( Color(Color.WHITE, 0.0) )
		set_visible(false)
		set_process_mode.bind(Node.PROCESS_MODE_DISABLED).call_deferred()
	else: 
		if alpha_tween != null: 
			if alpha_tween.is_valid():
				alpha_tween.kill()
		alpha_tween = get_tree().create_tween()
		alpha_tween.tween_method(set_modulate, current_color, Color(Color.WHITE, 0.0) , ALPHA_DURATION)
		alpha_tween.tween_callback(set_process_mode.bind(Node.PROCESS_MODE_DISABLED))
		alpha_tween.tween_callback(set_visible.bind(false))

func _get_doors() -> Array[Door]:
	var out : Array[Door] = []
	for each_child in get_children():
		if each_child is Door:
			out.append(each_child)
	return out

func has_door_for(_room_type: RoomTypes) -> bool:
	for each_door in _get_doors():
		if each_door.room_type == _room_type:
			return true
	return false

func get_door_from(_room_type: RoomTypes) -> Door:
	var doors : Array[Door] = []
	for each_door in _get_doors():
		if each_door.room_type == _room_type:
			doors.append(each_door)
	if doors.is_empty():
		return null
	return doors.pick_random()

static func get_room(target_room_type: Room.RoomTypes, source_room_type: Room.RoomTypes) -> Room: # will eventually ask for a room type
	var next_room : Room
	var filtered_rooms = room_list.filter(_filter_room_type.bind(target_room_type, source_room_type))
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

static func _filter_room_type(room: Room, target_room_type: Room.RoomTypes, source_room_type: Room.RoomTypes) -> bool:
	if target_room_type == RoomTypes.None or source_room_type == RoomTypes.None :
		return true
	return room.room_type == target_room_type and room.has_door_for(source_room_type)
