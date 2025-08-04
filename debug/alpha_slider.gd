extends HSlider

@export var alpha_target: Node2D

func _ready() -> void:
	value_changed.connect(_on_value_changed)

func _on_value_changed(_value: float) -> void: 
	if alpha_target: 
		alpha_target.self_modulate.a = _value
