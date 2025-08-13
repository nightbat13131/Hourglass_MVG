class_name SoundManager extends CanvasLayer


@onready var h_slider_master_volume: HSlider = %HSlider_Master
@onready var h_slider_music_volume: HSlider = %HSlider_Music
@onready var h_slider_sfx_volume: HSlider = %HSlider_SFX

@onready var _master_index := AudioServer.get_bus_index("Master")
@onready var _music_index := AudioServer.get_bus_index("Music")
@onready var _sfx_index := AudioServer.get_bus_index("Effects")
@onready var margin_container: CenterContainer = %MarginContainer


static var _current_manager : SoundManager


func _ready() -> void:
	
	h_slider_music_volume.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(_music_index))
	)
	h_slider_music_volume.value_changed.connect(_on_music_volume_change)
	h_slider_sfx_volume.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(_sfx_index))
	)
	h_slider_sfx_volume.value_changed.connect(_on_sfx_volume_change)
	h_slider_master_volume.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(_master_index))
	)
	h_slider_master_volume.value_changed.connect(_on_master_volume_change)
	if _current_manager == null:
		_current_manager = self
	else: 
		printerr("SoundManager mad about there already being a SoundManager, singleton idea failed. Me: " , self._to_string(), " Current: " , _current_manager._to_string())


func _on_music_volume_change(new_percent: float) -> void: AudioServer.set_bus_volume_db(_music_index, linear_to_db(new_percent))

func _on_sfx_volume_change(new_percent: float) -> void: AudioServer.set_bus_volume_db(_sfx_index, linear_to_db(new_percent))

func _on_master_volume_change(new_percent: float) -> void: AudioServer.set_bus_volume_db(_master_index, linear_to_db(new_percent))
