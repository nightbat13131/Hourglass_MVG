extends DoorImage

const GLASS_PATH := 'uid://cm2tkjnd7itvf'

var _close_frame := 0 # first frame
var _peek_frame := 1
var _open_frame := 1 # last frame

func setup_texture_door(value: DoorMaterial) -> void:
	if value == DoorMaterial.GLASS:
		set_texture(load(GLASS_PATH))
	_open_frame = int(get_texture().get_size().x/(48*2))-1
	set_hframes(
		_open_frame+1
	)

func peek() -> void:
	end_tween()
	set_frame(_peek_frame)

func open(fast:= false) -> void:
	if fast:
		end_tween()
		set_frame(_open_frame)
		set_modulate(_open_modulate)
		return
	clean_tweener()
	var start_frame = get_frame()
	_open_tweener.tween_method(set_frame, start_frame, _open_frame, FULL_DURATION)
	_open_tweener.tween_method(set_modulate, get_modulate(), _open_modulate, FULL_DURATION )

func close(fast:= false) -> void:
	clean_tweener()
	if fast: 
		end_tween()
		set_frame(_close_frame)
		set_modulate(_close_modulate)
		return
	clean_tweener()
	var start_frame = get_frame()
	_open_tweener.tween_method(set_frame, start_frame, _close_frame, FULL_DURATION )
	_open_tweener.tween_method(set_modulate, get_modulate(), _close_modulate, FULL_DURATION )
