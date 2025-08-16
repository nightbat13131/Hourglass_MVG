class_name World extends Node2D

@export var initial_room : Room

static var world : World

func _ready() -> void:
	world = self
	initial_room.set_global_position(Vector2.ZERO)
	initial_room.activate(true)

static func get_world() -> World: return world
