class_name InteractionResource extends Resource

signal state_changed

enum States {
	NA = 0, # treat as a null state
	ACTION_INIT = 3, 
	ACTION_SUCCESS = 2, 
	ACTION_FAILED = 11,
	ACTION_COMPLETE = 12
	}

@export var _state_details : Dictionary[States, InteractionStates] = {
	States.ACTION_INIT : InteractionStates.new(),
	States.ACTION_SUCCESS : InteractionStates.new(),
	States.ACTION_COMPLETE : InteractionStates.new(),
}

var _state := States.ACTION_INIT

func get_text() -> String: 
	var text := ""
	if _state == States.ACTION_INIT:
		text += Utilities.get_action_button()
	text += get_state_details().get_text()
	return text

func get_frame_cords() -> Vector2i: return get_state_details().get_sprite_frame_cord()

func get_sprite_color() -> Color: return get_state_details().get_sprite_color()

func get_highlight_color() -> Color: return get_state_details().get_highlight_color()

func do_action() -> void:
	if _state == States.ACTION_INIT:
		if get_state_details().try_action():
			set_state(States.ACTION_SUCCESS)
		else: 
			set_state(States.ACTION_FAILED)
	elif _state == States.ACTION_SUCCESS:
		set_state(States.ACTION_COMPLETE)
	elif _state == States.ACTION_FAILED:
		set_state(States.ACTION_INIT)

func character_left() -> void:
	if _state == States.ACTION_SUCCESS:
		set_state(States.ACTION_COMPLETE)
	elif _state == States.ACTION_FAILED:
		set_state(States.ACTION_INIT)

func set_state(new_state: States) -> void:
	if _state == new_state:
		return
	_state = new_state
	state_changed.emit()

func get_state_details() -> InteractionStates:
	var dets = _state_details.get(_state)
	if dets == null:
		printerr("state details missing for ", self, " for state ", _state)
		dets = InteractionStates.new()
	return dets

func is_complete() -> bool: return _state == States.ACTION_COMPLETE
