class_name DoorImage extends Sprite2D

enum DoorMaterial {WOOD = 1, GLASS = 2}

# var _open_percent := 0.0
var _open_tweener : Tween
var _open_modulate := Color.TRANSPARENT
var _close_modulate := Color.WHITE
const FULL_DURATION := .2

func _ready() -> void:
	close(true)
	show()

func open(fast:= false) -> void: pass

func close(fast:= false) -> void: pass

func peek() -> void: pass

func end_tween() -> void: 
	if _open_tweener:
		if _open_tweener.is_valid():
			_open_tweener.kill()

func clean_tweener() -> void:
	end_tween()
	_open_tweener = get_tree().create_tween()
	_open_tweener.set_parallel(true)
	_open_tweener.set_ease(Tween.EASE_IN)
	_open_tweener.set_trans(Tween.TRANS_CIRC)

func setup_texture_door(value: DoorMaterial) -> void:
	# used by frech door, not garage door
	pass
