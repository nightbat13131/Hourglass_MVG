class_name Hourglass extends Node2D

static var _current: Hourglass

# full is the number of activites to do in the world?
# the sand falls when you complete an activity ?


static var fall_speed := 1.0 # grain / second



@onready var label_top: Label = %Label_top
@onready var label_bottom: Label = %Label_bottom


var _active := false

var _top_value := 100.0: 
	set(value):
		if value < 0: 
			value = 0.0
		if value >= 0.0 and value != _top_value:
			_top_value = value
			label_top.set_text(str(_top_value))
var _bottom_value := 0.0: 
	set(value):
		if value > 0.0 and value != _bottom_value:
			_bottom_value = value
			label_bottom.set_text(str(_bottom_value))

func _ready() -> void:
	_current = self

func _process(delta: float) -> void:
	if _active:
		var sand_delta = fall_speed * delta
		_top_value -= sand_delta
		_bottom_value += sand_delta

func toggle_active() -> void:
	_active = !_active
