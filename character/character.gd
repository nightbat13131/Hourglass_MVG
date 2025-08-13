class_name Player extends CharacterBody2D
# animation logic https://www.youtube.com/watch?v=cnXmwMpn4pw
const DOWN = 'v'
const UP = '^'
const LEFT = '<'
const RIGHT = '>'
const STILL = 'still' # y = 0
const IDLE = 'idle' # y = 1
const WALK = 'walk' # y = 2



var _max_speed := Utilities.GRID_WIDTH * 7.0 # px per second
var _acceleration := _max_speed*  .75 
var _friction := _acceleration * 4.0
# var _speed := _max_speed
var _interactive : Interactive

var _is_walking := false : set = set_is_walking

@export var move: GUIDEAction
@export var interact: GUIDEAction

@onready var area_2d_reach: Area2D = %Area2D_Reach
@onready var action_label: Label = %ActionLabel

@onready var debug_text: Label = %debug_text
@onready var animation_tree: AnimationTree = $AnimationTree

var playback : AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = animation_tree['parameters/playback']
	area_2d_reach.body_entered.connect(_on_area_2d_reach_body_entered)
	area_2d_reach.body_exited.connect(_on_area_2d_reach_body_exited)
	_on_action_updated()
	set_is_walking(false)
	update_facing_direction()
	if !move:
		printerr("Move action missing from Character")
	if !interact:
		printerr("Interact action missing from Character")

func _process(delta: float) -> void:
	if interact.is_triggered() and has_interaction():
			_interactive.do_action()
	var old_speed = velocity.length()
	# https://www.youtube.com/watch?app=desktop&v=KceMokK2qFA
	if move.is_triggered():
		var direction = move.value_axis_2d.normalized()
		velocity = (old_speed*direction) + (direction * delta * _acceleration)  # turns seem to accelorate 
		# velocity += direction * delta * _acceleration  this makes for slippery walking. 
		velocity = velocity.limit_length(_max_speed)

	else: # come to a stop
		if velocity.length() >= delta * _friction:
			velocity -= velocity.normalized() * delta * _friction # apply friction
		else:
			velocity = Vector2.ZERO
	update_facing_direction()
	move_and_slide()
	#debug_text.set_text(str(_facing_direction))

func update_facing_direction() -> void:
	#print_debug(velocity)
	if is_equal_approx(velocity.length(), 0.0):
		set_is_walking(false)
		return # no movement, no turn
	var direction = velocity.normalized()
	set_is_walking(true)
	if abs(direction.x) == abs(direction.y) and direction.y < 0.0 : # ties looking up go to left/right
		direction.y = 0
	animation_tree['parameters/idle/blend_position'] = direction
	animation_tree['parameters/walk/blend_position'] = direction
	#debug_text.set_text(str(direction.normalized()) + str(velocity))

func set_is_walking(new_value: bool) -> void:
	#print_debug(new_value)
	if _is_walking == new_value:
		return 
	_is_walking = new_value
	animation_tree['parameters/conditions/is_walking'] = _is_walking
	animation_tree['parameters/conditions/is_idle'] = !_is_walking
	#print_debug(animation_tree['parameters/conditions/is_walking'], animation_tree['parameters/conditions/is_idle'])


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
