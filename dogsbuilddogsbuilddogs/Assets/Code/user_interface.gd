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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update(element_name: String, input: Variant) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	pass

## each index of this is a page's worth of text
var main_dialog_queue: PackedStringArray
## if the main thing is ready to be fed the next line
var main_dialog_ready: bool = true

func play_main_dialog(input: String = "") -> bool:
	if input != "":
		queue_into_dialog(input)
	elif main_dialog_queue.size() == 0:
		$DialogBoxAnimationPlayer.queue("hide_dialog_box")
		get_tree().create_tween().tween_callback($%MainDialogBox.clear).set_delay(0.3)
		return false
	
	if !$%MainDialogControl.visible:
		$DialogBoxAnimationPlayer.play("show_dialog_box")
		get_tree().create_tween().tween_callback(play_main_dialog).set_delay(0.4)
		return true
	
	if main_dialog_ready:
		advance_dialog()
		return true
	else:
		dialog_tween.kill()
		$%MainDialogBox.add_text(main_dialog_queue[0])
		main_dialog_queue.remove_at(0)
		main_dialog_ready = true
		return true

func show_dialog_box():
	$DialogBoxAnimationPlayer.queue("show_dialog_box")
func hide_dialog_box():
	$DialogBoxAnimationPlayer.queue("hide_dialog_box")

# doesn't support custom fonts. i could have made it do that and decided not to. haha im evil. haha.
# not like i spent 30 minutes trying to figure out how to get the characters only to realize that
# it's a property and not a method
# also doesn't work well when words are longer than the max characters
# and in the end that didn't work so you have to define the max length. yay
# fuck it i'll implement the font agile one anyway so we don't need to use monospaced
func queue_into_dialog(text: String, dialog_box: RichTextLabel = $%MainDialogBox) -> void:
	var max_height = dialog_box.size.y
	var max_length = dialog_box.size.x
	
	if dialog_box == $%MainDialogBox:
		main_dialog_queue.clear()
	dialog_box.clear()
	
	var words: PackedStringArray = text.split(" ", false)
	
	#print("Max length: %s Max height: %s" % [max_length, max_height])
	
	var height_count: int = 0 # in pixels
	var length_count: int = 0
	var phrase_height: int = dialog_box.get_theme_font("font").get_string_size("qwertyuiopasdfghjkl;zxcvbnm .,", HORIZONTAL_ALIGNMENT_LEFT, -1, dialog_box.get_theme_font_size("normal_font_size")).y # look man it works
	var resulting_pages: Array[String] = [""]
	var page_index: int = 0
	
	for word in words:
		# long line incoming 
		var phrase_length = dialog_box.get_theme_font("font").get_string_size(word + " ", HORIZONTAL_ALIGNMENT_LEFT, -1, dialog_box.get_theme_font_size("normal_font_size")).x
		if phrase_length + length_count > max_length:
			length_count = 0
			resulting_pages[page_index] += "\n"
			#print(height_count, "h + ", phrase_height, " vs ", max_height)
			if height_count + phrase_height > max_height:
				height_count = 0
				page_index += 1
				resulting_pages.append("")
			else:
				height_count += phrase_height
		#print(length_count, "l + ", phrase_length, " vs ", max_length)
		length_count += phrase_length
		resulting_pages[page_index] += word + " "
	
	print(resulting_pages)
	main_dialog_queue.append_array(resulting_pages)

## starts the next page
func advance_dialog(dialog_box: RichTextLabel = $%MainDialogBox):
	main_dialog_ready = false
	dialog_box.clear()
	dialog_tween = get_tree().create_tween().set_loops(main_dialog_queue[0].length())
	dialog_tween.tween_callback(type_next_main_char.bind(dialog_box)).set_delay(0.01)

## helper method for turn_into_dialog
func type_next_main_char(dialog_box: RichTextLabel) -> void:
	dialog_box.add_text(main_dialog_queue[0][0])
	main_dialog_queue[0] = main_dialog_queue[0].substr(1)
	if main_dialog_queue[0].length() == 0:
		main_dialog_queue.remove_at(0)
		main_dialog_ready = true

func _on_tab_bar_tab_clicked(tab: int) -> void:
	selection = tab


func _on_tab_bar_mouse_exited() -> void:
	if selection > -1:
		central_node.holdMakeBuilding(selection)
		selection = -1
