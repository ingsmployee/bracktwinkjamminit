extends Control # originally TabContainer

const INIT_SOUND_VOLUME: int = 70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# i know
	for child: Range in find_children("*", "Range"):
		child.value = INIT_SOUND_VOLUME
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	pass

var fading_tween: Tween
func fade_in() -> void:
	show()
	if fading_tween:
		fading_tween.kill()
	fading_tween = get_tree().create_tween()
	fading_tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func fade_out() -> void:
	if fading_tween:
		fading_tween.kill()
	fading_tween = get_tree().create_tween()
	fading_tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fading_tween.tween_callback(hide).set_delay(0)


func change_sound_volume(bus: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), lerp(-24.0, 6.0, value/100))

# yes i know this loops. there is no time
func _on_sounds_master_slider_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/Master/SpinBox".value = value
	change_sound_volume("Master", value)
func _on_sounds_master_spin_box_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/Master/HSlider".value = value
	change_sound_volume("Master", value)

func _on_sounds_music_slider_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/Music/SpinBox".value = value
	change_sound_volume("Music", value)

func _on_sounds_music_spin_box_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/Music/HSlider".value = value
	change_sound_volume("Music", value)


func _on_sounds_ui_slider_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/UserInterface/SpinBox".value = value
	change_sound_volume("UI Sounds", value)
func _on_sounds_ui_spin_box_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/UserInterface/HSlider".value = value
	change_sound_volume("UI Sounds", value)


func _on_sounds_game_slider_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/GameAudio/SpinBox".value = value
	change_sound_volume("Ingame SFX", value)
func _on_sounds_game_spin_box_value_changed(value: float) -> void:
	if not visible: return
	$"SettingsStuff/GameAudio/HSlider".value = value
	change_sound_volume("Ingame SFX", value)

func _on_exit_button_pressed() -> void:
	fade_out()
