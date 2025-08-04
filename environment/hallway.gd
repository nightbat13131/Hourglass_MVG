extends Node2D

@export var walking_mode : GUIDEMappingContext

func _ready() -> void:
	GUIDE.enable_mapping_context(walking_mode)
