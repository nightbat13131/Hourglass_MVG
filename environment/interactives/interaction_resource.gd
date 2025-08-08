class_name InteractionResource extends Resource

signal state_changed

enum InteractionTypes {
	FURNITURE = 0, # stove
	PICKUP = 1, # key
	PICKUP_ECHO= 2, # Leaves a memory behind
}

enum States {
	NA = 0, # treat as a null state
	ACTION_READY = 3, 
	ACTION_HAPPENING = 1, 
	ACTION_HAPPENED = 2, 
	PICKED_UP = 10, 
	}

@export var interaction_type := InteractionTypes.FURNITURE

@export var initial_state := States.NA


@export var state_texts : Dictionary[States, String]
@export var state_frame_cords : Dictionary[States, Vector2i] # -1, -1 means hidden ?

@export var inventory_icon : PackedScene # 48*48 icon for showing in inventory

var _state := States.ACTION_READY

func _ready() -> void:
	if initial_state == States.NA:
		printerr("inital state not set for ", self)
	else:
		set_state(initial_state)

func get_text() -> String:
	var text := ""
	if _state in [States.ACTION_READY]:
		text += Utilities.get_action_button()
	text += state_texts.get(_state, "")
	return text

func get_frame_cords() -> Vector2i:
	return state_frame_cords.get(_state, Vector2.ZERO)

func get_image_color() -> Color:
	if _state in [States.PICKED_UP] and interaction_type == InteractionTypes.PICKUP:
		return Color.TRANSPARENT
	return Color.WHITE

func get_highlight_color() -> Color:
	if _is_completed() or [States.ACTION_HAPPENING].has(_state):
		return Color.TRANSPARENT
	return Color.WHITE

func do_action() -> void:
	if _state == States.ACTION_READY:
		if [InteractionTypes.PICKUP].has(interaction_type):
			Player.pickup_item(self)
			set_state(States.PICKED_UP)
		else:
			set_state(States.ACTION_HAPPENING)

func character_left() -> void:
	if _state == States.ACTION_HAPPENING:
		if interaction_type in [InteractionTypes.PICKUP]:
			set_state(States.PICKED_UP)
		else:
			set_state(States.ACTION_HAPPENED)

func character_entered() -> void:
	# check for dependency 
	pass

func set_state(new_state: States) -> void:
	if _state == new_state:
		return
	_state = new_state
	state_changed.emit()

func _is_completed() -> bool:
	return _state in [States.ACTION_HAPPENED, States.PICKED_UP]
