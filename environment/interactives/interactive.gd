class_name Interactive extends StaticBody2D

signal action_updated

const SHADER_SCRIPT := 'uid://22opvb4ikfpf'
const SPRITE_MODULATE := 'modulate_color'
const SPRITE_OUTLINE := 'outline_color'
const SPRITE_REGION := 'texture_region'

@export var _res : InteractionResource
var sprite_2d: Sprite2D # sprite sheet
var shader : Material # Shader

func _ready() -> void:
	if sprite_2d == null: # or texture_rect == null:
		for each_child in get_children():
			if each_child is Sprite2D:
				sprite_2d = each_child
				break
			#elif each_child is TextureRect:
			#	texture_rect = each_child
	_init_shader()
	if _res:
		# _res = _res.duplicate() # was testing repeated item
		_res.state_changed.connect(_on_res_state_changed)
	else: 
		printerr("No resource for ", self)
	update_visual()
	InteractionManager.add_interaction(self)

func get_text() -> String: return _res.get_text()

func update_visual() -> void:
	sprite_2d.set_frame_coords(_res.get_frame_cords())
	shader.set_shader_parameter(SPRITE_MODULATE, _res.get_sprite_color())
	shader.set_shader_parameter(SPRITE_OUTLINE, _res.get_highlight_color())

func do_action() -> void:
	_res.do_action()

func _on_res_state_changed() -> void:
	action_updated.emit()
	update_visual()
	if _res.is_complete():
		InteractionManager.interaction_complete(self)

func character_left() -> void:
	_res.character_left()

func character_entered() -> void:
	# _res.character_entered()
	pass

func _init_shader() -> void:
	if !sprite_2d:
		return
	if !sprite_2d.get_material():
		sprite_2d.set_material(ShaderMaterial.new())
	sprite_2d.get_material().set_shader(load(SHADER_SCRIPT))
	shader = sprite_2d.get_material()#.get_shader()
	shader.set_shader_parameter('outline_width', 3.0)

#func set_collision_enabled(is_enabled: bool) -> void:
	# same name as TileMapLayer function to support propigate 
	# Turns out I don't need this based on how StaticBody2D already handles Node.PROCESS_MODE_DISABLED
	# DISABLE_MODE_REMOVE = 0
	# When Node.process_mode is set to Node.PROCESS_MODE_DISABLED, remove from the physics simulation to stop all physics interactions with this CollisionObject2Dpass
	
