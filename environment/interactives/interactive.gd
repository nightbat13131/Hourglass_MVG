class_name Interactive extends StaticBody2D

signal action_updated

@export var _res : InteractionResource
var sprite_2d: Sprite2D # sprite sheet
var texture_rect: TextureRect # white highlight background

func _ready() -> void:
	
	if sprite_2d == null or texture_rect == null :
		for each_child in get_children():
			if each_child is Sprite2D:
				sprite_2d = each_child
			elif each_child is TextureRect:
				texture_rect = each_child
	if _res:
		_res = _res.duplicate()
		_res.state_changed.connect(_on_res_state_changed)
	else: 
		printerr("No resource for ", self)
	update_visual()

func get_text() -> String: return _res.get_text()

func update_visual() -> void:
	sprite_2d.set_frame_coords(_res.get_frame_cords())
	sprite_2d.set_modulate(_res.get_sprite_color())
	texture_rect.set_modulate(_res.get_highlight_color())

func do_action() -> void:
	_res.do_action()

func _on_res_state_changed() -> void:
	action_updated.emit()
	update_visual()

func character_left() -> void:
	_res.character_left()

func character_entered() -> void:
	# _res.character_entered()
	pass
