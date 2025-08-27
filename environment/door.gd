@tool
class_name Door extends Node2D

# inside dooor
# outside door
# glass door
# green house
# brown house


static var _last_synced_doors : Array[Door]

static var _all_doors : Array[Door]

@export var _true_partner_door: Door

@export var _is_stairs := false
@export var _is_car_garage := false
@export var _door_material := DoorImage.DoorMaterial.WOOD

@onready var area_player_average: Area2D = %Area_PlayerAverage
@onready var area_2d_close_door_inside: Area2D = %Area2D_close_door_inside
@onready var area_2d_close_door_outside: Area2D = %Area2D_close_door_outside
@onready var area_2d_sleep_helper: Area2D = %Area2D_sleep_helper
@onready var area_2d_visual_helper: Area2D = %Area2D_visual_helper

@onready var _garage_image: DoorImage = %GarageImage
@onready var _door_image: DoorImage = %DoorImage

var image : DoorImage

var parent_room : Room
var _temp_partner_door: Door


var _is_asleep := false: set = set_is_asleep
var _player_found := false
var _player_inside := false
var _player_outside := false

var _is_open := false

func _ready() -> void:
	Utilities.snap_to_interval(self, 2)
	if Engine.is_editor_hint():
		return
	set_modulate(Color.WHITE)
	_door_setup_check()
	
	_all_doors.append(self)
	area_player_average.body_entered.connect(_on_body_change.bind(true, area_player_average ))
	area_player_average.body_exited.connect(_on_body_change.bind(false, area_player_average))
	area_2d_close_door_inside.body_entered.connect(_on_body_change.bind(true,area_2d_close_door_inside ))
	area_2d_close_door_inside.body_exited.connect(_on_body_change.bind(false, area_2d_close_door_inside))
	area_2d_close_door_outside.body_entered.connect(_on_body_change.bind(true, area_2d_close_door_outside))
	area_2d_close_door_outside.body_exited.connect(_on_body_change.bind(false, area_2d_close_door_outside))
	area_2d_sleep_helper.body_exited.connect(_on_area_2d_sleep_helper_body_exited)
	area_2d_visual_helper.body_entered.connect(_on_area_2d_visual_helper_body_entered)
	area_2d_visual_helper.body_exited.connect(_on_area_2d_visual_helper_body_exited)
	if _is_car_garage:
		_door_image.queue_free()
		image = _garage_image
		var coll_height: float
		for each_collision_shape : CollisionShape2D in [ %CollisionShape_Player, %CollisionShape2D_inside, %CollisionShape2D_outside, %CollisionShape2D_Sleep, %CollisionShape2D]:
			# assuming all rectangles
			each_collision_shape.set_shape( each_collision_shape.get_shape().duplicate())
			coll_height = each_collision_shape.get_shape().size.y
			each_collision_shape.get_shape().size.y = coll_height *2
	else: 
		_garage_image.queue_free()
		image = _door_image
		if _is_stairs: # stairs graphic handled on map, not here
			_door_image.set_texture(null)
		else:
			image.setup_texture_door(_door_material)
	if !_is_stairs:
		image.show()

func get_connected_room_type() -> Room.RoomTypes:
	if _true_partner_door != null:
		return _true_partner_door.get_parent_room_type()
	else:
		printerr(self, " is missing a _true_partner_door")
	return Room.RoomTypes.None

func get_parent_room_type() -> Room.RoomTypes:
	if parent_room: 
		return parent_room.get_room_type()
	else: 
		printerr(self, " has no parent room")
		return Room.RoomTypes.None

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2.from_angle( 0 * (PI/2.0) )*Utilities.GRID_WIDTH*3, Color.WHEAT, 3.0)
		draw_line(Vector2.from_angle( 1 * (PI/2.0) )*Utilities.GRID_WIDTH, Vector2.from_angle( -1 * (PI/2.0) )*Utilities.GRID_WIDTH, Color.BLUE, 2.0)

func _on_area_entered(_area: Area2D) -> void:
	_open_door()

func sync_with(partner: Door) -> void:
	var _old_rooms : Array[Room] = []
	# deactivating old rooms if they fail to deactivate correctly
	for each_door0 in _last_synced_doors:
		_old_rooms.append(each_door0.parent_room)
	_last_synced_doors = [self, partner]
	_temp_partner_door = partner
	for each_door1 in _last_synced_doors: # don't erase any rooms that are for the current doors
		_old_rooms.erase(each_door1.parent_room)
	for each_room in _old_rooms:
		each_room.deactivate(true)
	parent_room.summon(partner, self)
	set_is_asleep(true) # needs to not trigger functionality untill the overlapped door is done

func _open_door() -> void:
	## Completed rooms are easier to get to, but not leave. 
	if _true_partner_door.parent_room.are_interactions_complete():
		_temp_partner_door = _true_partner_door
	elif !_last_synced_doors.has(self) or _temp_partner_door == null:
		_temp_partner_door = _find_temp_match_door()
	if _temp_partner_door == null:
		printerr("_temp_partner_door still null")
		return
	_temp_partner_door.sync_with(self)
	_is_open = true
	if !_is_stairs:
		image.open()
	#set_modulate(Color.ORANGE_RED)

func _close_door() -> void:
	_is_open = false
	if !_is_stairs:
		image.close()

func _on_body_change(body: Node2D, is_entering: bool, area: Area2D) -> void:
	if !body is Player:
		return
	match area:
		area_player_average:
			_player_found = is_entering
			area_player_average.set_visible(is_entering)
		area_2d_close_door_inside:
			_player_inside = is_entering
			area_2d_close_door_inside.set_visible(is_entering)
		area_2d_close_door_outside:
			_player_outside = is_entering
			area_2d_close_door_outside.set_visible(is_entering)
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
	if posible_doors.is_empty():
		printerr("no match found for get_connected_room_type ", get_connected_room_type(), " while in parent_room ", parent_room, ". ", self)
		return null
	return posible_doors.pick_random()

func __door_match_filter(potental_door: Door) -> bool:
	if potental_door._is_stairs != _is_stairs:
		return false
	if potental_door._is_car_garage != _is_car_garage:
		return false
	if potental_door.parent_room == parent_room: # no looping into self
		return false
	if potental_door.parent_room.get_room_type() != get_connected_room_type():  # door is for the wrong kind of room
		return false
	if potental_door.get_connected_room_type() != parent_room.get_room_type():
		return false # door could not lead back here
	return true

func _on_area_2d_sleep_helper_body_exited(body: Node2D) -> void:
	if body is Player:
		set_is_asleep(false)

func set_is_asleep(is_asleep: bool) -> void:
	if _is_asleep != is_asleep:
		_is_asleep = is_asleep
		area_2d_sleep_helper.set_visible(_is_asleep)
		if _is_asleep:
			if !_is_stairs:
				image.open(true)

func _on_area_2d_visual_helper_body_entered(body: Node2D) -> void:
	if body is Player and !_is_asleep:
		if !_is_stairs:
			image.peek()

func _on_area_2d_visual_helper_body_exited(body: Node2D) -> void:
	if body is Player:
		if !_is_stairs:
			image.close()

static func get_last_room() -> Room:
	if _last_synced_doors.is_empty():
		return null
	return _last_synced_doors[-1].get_parent()

func _door_setup_check() -> void:
	var text: String = " : "
	if _true_partner_door == null:
		text += "_true_partner_door is null."
	else:
		if _true_partner_door._true_partner_door != self:
			text += "my true partner does not point back at me: _true_partner_door._true_partner_door = " 
			text += str(_true_partner_door)
	if text.length() >= 4:
		printerr(self, text)
