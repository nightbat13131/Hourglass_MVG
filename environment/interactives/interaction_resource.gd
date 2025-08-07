class_name InteractionResource extends Resource

signal state_changed

enum States {PRE = 0, DURRING = 1, POST = 2}

@export_multiline var pre_text : String
@export var pre_sprite_frame : Vector2i
@export_multiline var durring_text : String
@export var durring_sprite_frame : Vector2i
@export_multiline var post_text : String
@export var post_sprite_frame : Vector2i

var _state := States.PRE

var _is_completed := false

func get_text() -> String:
	match _state:
		States.PRE:
			return Utilities.get_action_button() + pre_text
		States.DURRING:
			return durring_text
	return post_text

func get_frame() -> Vector2i:
	match _state:
		States.PRE:
			return pre_sprite_frame
		States.DURRING:
			return durring_sprite_frame
	return post_sprite_frame

func do_action() -> void:
	if _state == States.PRE:
		set_state(States.DURRING)
		state_changed.emit()

func character_left() -> void:
	if _state == States.DURRING:
		set_state(States.POST)

func set_state(new_state: States) -> void:
	if _state == new_state:
		return
	_state = new_state
	if _state == States.POST:
		_is_completed = true
	state_changed.emit()

func is_completed() -> bool:
	return _is_completed
