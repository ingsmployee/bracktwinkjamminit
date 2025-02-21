extends Control

const MAIN_SCENE_PATH: String = "res://assets/scenes/main.tscn"
var loading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


var progress_arr: Array[float]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loading:
		match ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH, progress_arr):
			0: # not loading or invalid
				push_error_text("Invalid file!")
			1: # being loaded
				$LoadingBar.value = progress_arr[0] * 100
			2: # loading failed
				pass
			3: # loading finished
				get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(MAIN_SCENE_PATH))

func push_error_text(input: String):
	pass

func _on_button_down() -> void:
	SoundEffects.play("button_pressed")
	pass # Replace with function body.
	# all buttons hit here. play a sound effect

func _on_button_up() -> void:
	pass # Replace with function body.
	# same thing, sound effect

func begin_loading_new() -> void:
	loading = true
	$LoadingBar.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($LoadingBar, "modulate", Color(1,1,1,1), 1).set_ease(Tween.EASE_OUT)
	ResourceLoader.load_threaded_request(MAIN_SCENE_PATH)



func _on_play_game_pressed() -> void:
	begin_loading_new()

func _on_load_save_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_game_pressed() -> void:
	get_tree().quit()
