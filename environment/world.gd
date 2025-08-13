extends Node2D


@export var initial_room : Room

func _ready() -> void:

	initial_room.set_global_position(Vector2.ZERO)
	initial_room.activate(true)
