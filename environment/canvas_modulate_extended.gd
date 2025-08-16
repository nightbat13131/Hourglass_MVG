class_name AmbientColor extends CanvasModulate

@export var color_scale : Gradient

static var _instance : AmbientColor

var domain := 0.0:
	set(value):
		domain = value
		_color_from_gradiant()

func _ready() -> void:
	_instance = self
	set_visible(true)
	_color_from_gradiant()
	pass

#func _process(delta: float) -> void:
	#domain += .1 * delta
	#_color_from_gradiant()

func _color_from_gradiant() -> void:
	set_color(color_scale.sample(domain))

static func update_domain(value: float) -> void:
	if _instance:
		_instance.domain = value
