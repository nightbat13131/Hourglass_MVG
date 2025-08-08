class_name Player extends CharacterBody2D

var _max_speed := Utilities.GRID_WIDTH * 10.0 # px per second
var _acceleration := Utilities.GRID_WIDTH / 4.0 #px per second2
var _speed := _max_speed
var _facing_direction := Vector2.LEFT
var _interactive : Interactive

static var inventory : Array[InteractionResource]

@export var move: GUIDEAction
@export var interact: GUIDEAction

@onready var area_2d_reach: Area2D = %Area2D_Reach
@onready var action_label: Label = %ActionLabel

func _ready() -> void:
	area_2d_reach.body_entered.connect(_on_area_2d_reach_body_entered)
	area_2d_reach.body_exited.connect(_on_area_2d_reach_body_exited)
	_on_action_updated()
	if !move:
		printerr("Move action missing from Character")
	if !interact:
		printerr("Interact action missing from Character")

func _process(delta: float) -> void:
	# velocity += move.value_axis_2d.normalized() * _acceleration
	velocity = move.value_axis_2d.normalized() * _speed
	_facing_direction.y = 1 if velocity.y > 0 else -1
	_facing_direction.x = 1 if velocity.x > 0 else -1
	# prints("velocity: ", velocity, "move: ", move.value_axis_2d.normalized(), "length: ", velocity.length())
	# velocity vector in pixels per second, used and modified during calls to
	move_and_slide()
	if interact.value_bool:
		if has_interaction():
			#print("do action")
			_interactive.do_action()

func has_interaction() -> bool:
	return !_interactive == null

func _on_area_2d_reach_body_entered(body: Node2D) -> void:
	if body is Interactive:
		connect_action(body)

func connect_action(thing: Interactive) -> void:
	if has_interaction():
		if _interactive != thing:
			clear_action()
	_interactive = thing
	_interactive.character_entered()
	if !_interactive.action_updated.is_connected(_on_action_updated):
		_interactive.action_updated.connect(_on_action_updated)
	_on_action_updated()

func _on_area_2d_reach_body_exited(body: Node2D) -> void:
	if body is Interactive:
		clear_action()

func _on_action_updated() -> void:
	if has_interaction():
		set_action_label(_interactive.get_text())
	else:
		clear_action()

func clear_action() -> void:
	if has_interaction():
		if _interactive.action_updated.is_connected(_on_action_updated):
			_interactive.action_updated.disconnect(_on_action_updated)
		_interactive.character_left()
		_interactive = null
	set_action_label("")

func set_action_label(text: String) -> void:
	if action_label.get_text() == text:
		return
	action_label.set_text(text)
	action_label.set_visible(text.length() > 1)

static func pickup_item(thing: InteractionResource) -> void:
	if inventory.has(thing):
		printerr("Player already has ", thing)
		return
	inventory.append(thing)

static func check_inventory(thing: InteractionResource) -> bool:
	return inventory.has(thing)
