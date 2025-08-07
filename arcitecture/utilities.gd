class_name Utilities extends RefCounted

const GRID_WIDTH = 48
const GRID_HEIGHT = GRID_WIDTH

static func get_action_button() -> String:
	return "[E] : "

static func snap_to_interval(node: Node2D, interval_size: int) -> void:
	var interval = Utilities.GRID_HEIGHT/interval_size
	var x_mod = round(node.position.x/interval)
	var y_mod = round(node.position.y/interval)
	node.set_position(Vector2(x_mod*interval, y_mod*interval))
