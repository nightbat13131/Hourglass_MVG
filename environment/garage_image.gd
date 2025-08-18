extends DoorImage

# sprite region
var _full_closed_rect := Rect2(96.0, 0.0, 96, 192)
var _full_open_rect := Rect2(15.0, 0.0, 96, 192)
var _peek_open_rect := Rect2(96.0 - 15.0, 0.0, 96, 192)
# Rect2(x, y, width, height)


func peek() -> void:
	clean_tweener()
	var start = get_region_rect()
	_open_tweener.tween_method(set_region_rect, start, _peek_open_rect, .1 )

func open(fast:= false) -> void:
	if fast:
		end_tween()
		set_region_rect(_full_open_rect)
		set_modulate(_open_modulate)
		return
	clean_tweener()
	var start_rect = get_region_rect()
	_open_tweener.tween_method(set_region_rect, start_rect, _full_open_rect, FULL_DURATION)
	_open_tweener.tween_method(set_modulate, get_modulate(), _open_modulate, FULL_DURATION )

func close(fast:= false) -> void:
	clean_tweener()
	if fast: 
		end_tween()
		set_region_rect(_full_closed_rect)
		set_modulate(_close_modulate)
		return
	clean_tweener()
	var start_rect = get_region_rect()
	_open_tweener.tween_method(set_region_rect, start_rect, _full_closed_rect, FULL_DURATION )
	_open_tweener.tween_method(set_modulate, get_modulate(), _close_modulate, FULL_DURATION )
