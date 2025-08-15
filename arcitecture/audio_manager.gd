class_name AudioManager extends CenterContainer


@onready var h_slider_master: HSlider = %HSlider_master

@onready var _master_index := AudioServer.get_bus_index("Master")
#@onready var _music_index := AudioServer.get_bus_index("Music")
#@onready var _sfx_index := AudioServer.get_bus_index("Effects")

func _ready() -> void:
	
	h_slider_master.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(_master_index))
	)
	h_slider_master.value_changed.connect(_on_master_volume_change)

func _on_master_volume_change(new_percent: float) -> void: AudioServer.set_bus_volume_db(_master_index, linear_to_db(new_percent))
