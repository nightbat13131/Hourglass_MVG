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
	#for each_door in Door._last_synced_doors:
	#	each_door.parent_room.activate(false)
	
	var emergancy_door := Door._last_synced_doors[0]
	emergancy_door._open_door()
	
	#var emergancy_room := emergancy_door.parent_room
	#emergancy_room.activate(false)
	
	Player.get_player().set_global_position(emergancy_door.get_global_position())
