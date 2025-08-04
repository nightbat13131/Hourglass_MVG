class_name Character extends CharacterBody2D

var _max_speed := 100.0 # px per second
var _acceleration := 5.0 #px per second2
var _speed := _max_speed



@export var move: GUIDEAction

func _process(delta: float) -> void:
	
	# velocity += move.value_axis_2d.normalized() * _acceleration
	velocity = move.value_axis_2d.normalized() * _speed
	# prints("velocity: ", velocity, "move: ", move.value_axis_2d.normalized(), "length: ", velocity.length())
	# velocity vector in pixels per second, used and modified during calls to
	
	move_and_slide()
	
