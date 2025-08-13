extends Node2D

@export var walking_mode : GUIDEMappingContext
@onready var sound_button: Button = %SoundButton
@onready var world: Node2D = %World
@onready var sound_manager: SoundManager = %SoundManager

func _ready() -> void:
	# GUIDE.enable_mapping_context(walking_mode)
	sound_button.toggled.connect(_on_sound_button_toggle)
	_on_sound_button_toggle(false)

func _on_sound_button_toggle(is_pressed) -> void:
	sound_manager.set_visible(is_pressed)
	if is_pressed:
		GUIDE.disable_mapping_context(walking_mode)
		world.set_process_mode(Node.PROCESS_MODE_DISABLED)
	else:
		GUIDE.enable_mapping_context(walking_mode)
		world.set_process_mode(Node.PROCESS_MODE_INHERIT)
