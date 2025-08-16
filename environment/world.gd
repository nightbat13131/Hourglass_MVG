class_name World extends Node2D

@export var initial_room : Room

static var world : World

func _ready() -> void:
	world = self
	initial_room.set_global_position(Vector2.ZERO)
	initial_room.activate(true)

static func get_world() -> World: return world

func _process(_delta: float) -> void:
	if !Input.is_action_just_pressed("FellOutOfWorld"):
		return
	print_debug(Door._last_synced_doors)
	if Door._last_synced_doors.is_empty():
		return
	var emergacny_room = Door._last_synced_doors[0]
	Door._last_synced_doors[0].get_parent().activate(false)
	# puts me in the doorway, not the center of the room, but... I'm okay with that.
	Player.get_player().set_global_position(emergacny_room.get_global_position())
