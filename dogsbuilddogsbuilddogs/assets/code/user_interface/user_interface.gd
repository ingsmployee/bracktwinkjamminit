extends Control

# to do
# add actual random events
# add Safety building functionality for those events
# add lava pools
# add resource gathering

# write UI
# uh

@export var central_node: Node2D

var selection: int = -1

var ui := UI.new()
var dialog_tween: Tween

var shop_entry_scene: PackedScene = preload("res://assets/scenes/ui_elements/shop_entry.tscn")
var shop_icon_placeholder: Texture2D = preload("res://assets/art/programmer_art/programmer_building_icon_placeholder.png")

var bottom_bar_resting_x: Dictionary
var can_skip_dialog: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bottom_bar_resting_x["fun"] = $%FunCategory.position.x
	bottom_bar_resting_x["safe"] = $%SafeCategory.position.x
	bottom_bar_resting_x["factory"] = $%FactoryCategory.position.x
	
	var panel = $%FunCategory/Panel.duplicate()
	$%SafeCategory.add_child(panel.duplicate())
	$%FactoryCategory.add_child(panel)
	populate_shop()
	queue_dt_into_dialog("introduction_1")
	queue_dt_into_dialog("introduction_2")
	queue_dt_into_dialog("introduction_3")
	play_main_dialog()
	
	for button:BaseButton in find_children("*", "BaseButton", true):
		button.pressed.connect(play_button_noise)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$%MoneyCounter.text = "x %s" % GameResources.get_resource("money")

func _input(event: InputEvent):
	if event.is_action_pressed("escape"):
		go_down_a_level()
	if event.is_action_pressed("shift"):
		play_main_dialog()
	if event.is_action_pressed("toggle_hide_tutorial"):
		$%TutorialLabel.visible = not $%TutorialLabel.visible

## each index of this is a page's worth of text
var main_dialog_queue: PackedStringArray
## each index of this is an image to be used in parallel with main_dialog_queue
var main_image_queue: PackedStringArray
## if the main thing is ready to be fed the next line
var main_dialog_ready: bool = true
var current_dialog_image: String = ""

## fetches a DialogText from GameResources to be the dialog
func queue_dt_into_dialog(input: String):
	# accessing the DialogText then taking its contents
	var dialog: PackedStringArray = GameResources.dialog[input].dialog
	for index: int in range(0, dialog.size()/2):
		#print((index * 2), " ",dialog[index * 2], " " , (index * 2) + 1, dialog[(index * 2) + 1])
		queue_line_into_dialog(dialog[index * 2], dialog[(index * 2) + 1])

func play_main_dialog() -> bool:
	retract_bottom_bar()
	if main_dialog_queue.size() == 0:
		$%DialogBoxAnimationPlayer.queue("hide_dialog_box")
		return false
	
	if !$%MainDialogControl.visible:
		$%DialogBoxAnimationPlayer.play("show_dialog_box")
		$%MainDialogControl/DialogImage.texture = GameResources.alives_dialog_images[main_image_queue[0]]
		get_tree().create_tween().tween_callback(play_main_dialog).set_delay(0.4)
		return true
	
	if main_dialog_ready:
		advance_dialog()
		return true
	else: # if you mash the button, skip the dialog
		dialog_tween.kill()
		$%MainDialogBox.add_text(main_dialog_queue[0])
		main_dialog_queue.remove_at(0)
		main_image_queue.remove_at(0)
		main_dialog_ready = true
		return true

func show_dialog_box():
	$%DialogBoxAnimationPlayer.queue("show_dialog_box")
func hide_dialog_box():
	$%DialogBoxAnimationPlayer.queue("hide_dialog_box")

# doesn't support custom fonts. i could have made it do that and decided not to. haha im evil. haha.
# not like i spent 30 minutes trying to figure out how to get the characters only to realize that
# it's a property and not a method
# also doesn't work well when words are longer than the max characters
# and in the end that didn't work so you have to define the max length. yay
# fuck it i'll implement the font agile one anyway so we don't need to use monospaced
func queue_line_into_dialog(animal_image: String, text: String, dialog_box: RichTextLabel = $%MainDialogBox) -> void:
	var max_height = dialog_box.size.y
	var max_length = dialog_box.size.x
	
	var words: PackedStringArray = text.split(" ", false)
	
	#print("Max length: %s Max height: %s" % [max_length, max_height])
	
	var height_count: int = 0 # in pixels
	var lines_count: int = 0
	var length_count: int = 0
	var phrase_height: int = dialog_box.get_theme_font("font").get_string_size("qwertyuiopasdfghjkl;zxcvbnm .,", HORIZONTAL_ALIGNMENT_LEFT, -1, 150).y # look man it works
	var resulting_pages: Array[String] = [""]
	var page_index: int = 0
	
	for word in words:
		# long line incoming 
		var phrase_length = dialog_box.get_theme_font("font").get_string_size(word + " ", HORIZONTAL_ALIGNMENT_LEFT, -1, 150).x
		if phrase_length + length_count > max_length:
			length_count = 0
			resulting_pages[page_index] += "\n"
			lines_count += 1
			#print(height_count, "h + ", phrase_height, " vs ", max_height)
			if height_count + phrase_height > max_height or lines_count == 3:
				height_count = 0
				lines_count = 0
				page_index += 1
				resulting_pages.append("")
			else:
				height_count += phrase_height
		#print(length_count, "l + ", phrase_length, " vs ", max_length)
		length_count += phrase_length
		resulting_pages[page_index] += word + " "
	
	for i in resulting_pages:
		main_image_queue.append(animal_image)
	main_dialog_queue.append_array(resulting_pages)

## starts the next page
func advance_dialog(dialog_box: RichTextLabel = $%MainDialogBox):
	SoundEffects.play_dialog_start(main_image_queue[0])
	main_dialog_ready = false
	dialog_box.clear()
	dialog_tween = get_tree().create_tween()
	dialog_tween.set_loops(main_dialog_queue[0].length()).tween_callback(type_next_main_char.bind(dialog_box)).set_delay(0.01)
	if current_dialog_image != main_image_queue[0]:
		$%DialogImage.texture = GameResources.alives_dialog_images[main_image_queue[0]]
	current_dialog_image = main_image_queue[0]

## helper method for turn_into_dialog
func type_next_main_char(dialog_box: RichTextLabel) -> void:
	dialog_box.add_text(main_dialog_queue[0][0])
	main_dialog_queue[0] = main_dialog_queue[0].substr(1)
	if main_dialog_queue[0].length() == 0:
		main_dialog_queue.remove_at(0)
		main_image_queue.remove_at(0)
		main_dialog_ready = true

func go_down_a_level() -> void:
	if $%SettingsContainer.visible:
		$%SettingsContainer.fade_out()
		return
	
	_on_pause_button_pressed()

func populate_shop() -> void:
	for building_stats in GameResources.buildings:
		# print("Name: %s, Category: %s, Cost: %s" % [building_stats.building_name, building_stats.building_type, building_stats.cost["money"]])
		var shop_entry: TextureButton = shop_entry_scene.instantiate()
		var category: Control
		match building_stats.building_type: # reparent to a category
			0: # fun
				category = $%FunCategory
			1: # safe
				category = $%SafeCategory
			2: # industry
				category = $%FactoryCategory
		category.get_node("Panel/ScrollContainer/GridContainer").add_child(shop_entry)
		
		if building_stats.building_icon:
			shop_entry.get_node("TextureRect").texture = building_stats.building_icon
		else:
			shop_entry.get_node("TextureRect").texture = shop_icon_placeholder
		shop_entry.get_node("BuildingName").text = building_stats.building_name
		shop_entry.get_node("HBoxContainer/Cost").text = "x %s" % building_stats.cost["money"]
		shop_entry.pressed.connect(shop_button_clicked.bind(building_stats))
	

func shop_button_clicked(stats: BuildingStats):
	if GameResources.get_resource("money") < stats.cost["money"]:
		# happens when you can't afford the thing
		## NEED AN ANIMATION HERE OR A SOUND
		print("no money")
		return
	
	# building.gd will handle actually subtracting the money once the building is placed
	# ergo the money won't be subtracted if you're just holding the building
	central_node.hold_make_building(GameResources.building_scenes[stats.building_name])
	retract_bottom_bar()

var tasks_panel_shown: bool = true
func _on_tasks_panel_visibility_button_pressed() -> void:
	if tasks_panel_shown:
		tasks_panel_shown = false
		$%TasksPanelAnimationPlayer.play("hide_tasks_panel")
	else:
		tasks_panel_shown = true
		$%TasksPanelAnimationPlayer.play("show_tasks_panel")

# these should all be separate scripts for each category but. im in too deep. i think it is faster to write shit code
var selected_tab: String
var fun_category_tween: Tween
func _on_fun_icon_mouse_entered() -> void:
	if fun_category_tween:
		fun_category_tween.kill()
	fun_category_tween = get_tree().create_tween()
	fun_category_tween.tween_property($%FunCategory/Label, "position", Vector2(-16, -89), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_fun_icon_mouse_exited() -> void:
	if selected_tab != "fun":
		if fun_category_tween:
			fun_category_tween.kill()
		fun_category_tween = get_tree().create_tween()
		fun_category_tween.tween_property($%FunCategory/Label, "position", Vector2(-16, 168), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _on_fun_button_pressed() -> void:
	if selected_tab == "fun":
		return
	else:
		retract_bottom_bar()
	selected_tab = "fun"
	if fun_category_tween:
		fun_category_tween.kill()
	if wharha:
		wharha.kill()
	fun_category_tween = get_tree().create_tween()
	fun_category_tween.tween_property($%FunCategory, "position", Vector2(bottom_bar_resting_x["fun"], -410), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

var safe_category_tween: Tween
func _on_safe_icon_mouse_entered() -> void:
	if safe_category_tween:
		safe_category_tween.kill()
	safe_category_tween = get_tree().create_tween()
	safe_category_tween.tween_property($%SafeCategory/Label, "position", Vector2(-16, -89), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_safe_icon_mouse_exited() -> void:
	if selected_tab != "safe":
		if safe_category_tween:
			safe_category_tween.kill()
		safe_category_tween = get_tree().create_tween()
		safe_category_tween.tween_property($%SafeCategory/Label, "position", Vector2(-16, 168), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _on_safe_button_pressed() -> void:
	if selected_tab == "safe":
		return
	else:
		retract_bottom_bar()
	selected_tab = "safe"
	if safe_category_tween:
		safe_category_tween.kill()
	if wharhaa:
		wharhaa.kill()
	safe_category_tween = get_tree().create_tween()
	safe_category_tween.tween_property($%SafeCategory, "position", Vector2(bottom_bar_resting_x["safe"], -410), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

var industry_category_tween: Tween
func _on_factory_icon_mouse_entered() -> void:
	if industry_category_tween:
		industry_category_tween.kill()
	industry_category_tween = get_tree().create_tween()
	industry_category_tween.tween_property($%FactoryCategory/Label, "position", Vector2(-16, -89), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_factory_icon_mouse_exited() -> void:
	if selected_tab != "factory":
		if industry_category_tween:
			industry_category_tween.kill()
		industry_category_tween = get_tree().create_tween()
		industry_category_tween.tween_property($%FactoryCategory/Label, "position", Vector2(-16, 168), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _on_factory_button_pressed() -> void:
	if selected_tab == "factory":
		return
	else:
		retract_bottom_bar()
	selected_tab = "factory"
	if industry_category_tween:
		industry_category_tween.kill()
	if wharhaharah:
		wharhaharah.kill()
	industry_category_tween = get_tree().create_tween()
	industry_category_tween.tween_property($%FactoryCategory, "position", Vector2(bottom_bar_resting_x["factory"], -410), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

var wharha: Tween
var wharhaa: Tween
var wharhaharah: Tween
func retract_bottom_bar() -> void:
	if selected_tab != "":
		SoundEffects.play("woosh", "UI Sounds")
	else:
		return
	if wharha:
		wharha.kill()
		
	# used to be a match, but i can't afford to patch all of the "tab stays open" bugs sooo
	wharha = get_tree().create_tween()
	get_tree().create_tween().tween_property($%FunCategory/Label, "position", Vector2(-16, 168), 0.2)
	wharha.tween_property($%FunCategory, "position", Vector2(bottom_bar_resting_x["fun"], 0), 0.2).set_trans(Tween.TRANS_CIRC)
	if wharhaa:
		wharhaa.kill()
	wharhaa = get_tree().create_tween()
	get_tree().create_tween().tween_property($%SafeCategory/Label, "position", Vector2(-16, 168), 0.2)
	wharhaa.tween_property($%SafeCategory, "position", Vector2(bottom_bar_resting_x["safe"], 0), 0.2).set_trans(Tween.TRANS_CIRC)
	if wharhaharah:
		wharhaharah.kill()
	wharhaharah = get_tree().create_tween()
	get_tree().create_tween().tween_property($%FactoryCategory/Label, "position", Vector2(-16, 168), 0.2)
	wharhaharah.tween_property($%FactoryCategory, "position", Vector2(bottom_bar_resting_x["factory"], 0), 0.2).set_trans(Tween.TRANS_CIRC)
	selected_tab = ""

func _on_main_screen_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_primary"):
		retract_bottom_bar()

var paused: bool = false
var pause_tween: Tween
func _on_pause_button_pressed() -> void:
	paused = !paused
	# i dont care anymore
	# i do care but time is not with us
	if pause_tween:
		pause_tween.kill()
	pause_tween = get_tree().create_tween()
	
	if paused:
		pause_tween.tween_callback($%PauseMenuColorRect.show)
		pause_tween.tween_property($%PauseMenuColorRect, "modulate", Color(1,1,1,1), 0.3).set_ease(Tween.EASE_OUT)
	else:
		pause_tween.tween_property($%PauseMenuColorRect, "modulate", Color(1,1,1,0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		pause_tween.tween_callback($%PauseMenuColorRect.hide)

func play_button_noise() -> void:
	SoundEffects.play("button_pressed", "UI Sounds")


func _on_pause_settings_button_pressed() -> void:
	$%SettingsContainer.fade_in()


func _on_pause_exit_button_pressed() -> void:
	get_tree().quit()
