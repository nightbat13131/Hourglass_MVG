extends Node2D

@export var walking_mode : GUIDEMappingContext
@export var initial_room : Room

func _ready() -> void:
	GUIDE.enable_mapping_context(walking_mode)
	initial_room.activate(Vector2.ZERO, 0.0, true)
