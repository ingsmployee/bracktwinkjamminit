extends Control

# to do
# finish making vertical part of dialogue system
# add random events system
# add Safety building functionality
# write UI
# uh

@export var central_node: Node2D

var selection: int = -1

var ui := UI.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update(element_name: String, input: Variant) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("build_a"):
		turn_into_dialog("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud")

var main_dialog_string: String
var main_dialog_queue: PackedStringArray
## if the main thing is ready to be fed the next line
var main_dialog_ready: bool = true
# doesn't support custom fonts. i could have made it do that and decided not to. haha im evil. haha.
# not like i spent 30 minutes trying to figure out how to get the characters only to realize that
# it's a property and not a method
# also doesn't work well when words are longer than the max characters
# and in the end that didn't work so you have to define the max length. yay
# fuck it i'll implement the font agile one anyway so we don't need to use monospaced
func turn_into_dialog(text: String, delay: float = 0.05, dialog_box: RichTextLabel = $%MainDialogBox) -> void:
	var max_height = dialog_box.size.y
	var max_length = dialog_box.size.x
	
	if dialog_box == $%MainDialogBox:
		main_dialog_string = ""
	dialog_box.clear()
	
	var words: PackedStringArray = text.split(" ", false)
	main_dialog_string = ""
	
	var height_count: int = 0 # in pixels
	var length_count: int = 0
	var line_height = dialog_box.get_theme_font("font").get_height()
	
	for word in words:
		# long line incoming 
		var phrase_size = dialog_box.get_theme_font("font").get_string_size(word + " ", HORIZONTAL_ALIGNMENT_LEFT, -1, dialog_box.get_theme_font_size("font_size"))
		if phrase_size.x + length_count > max_length:
			main_dialog_string += "\n"
			length_count = 0
		main_dialog_string += word + " "
		length_count += phrase_size.x + 1
	
	var tween = get_tree().create_tween().set_loops(main_dialog_string.length())
	tween.tween_callback(type_next_main_char.bind(dialog_box)).set_delay(delay)

## helper method for turn_into_dialog
func type_next_main_char(dialog_box: RichTextLabel) -> void:
	dialog_box.add_text(main_dialog_string[0])
	main_dialog_string = main_dialog_string.substr(1)

func _on_tab_bar_tab_clicked(tab: int) -> void:
	selection = tab


func _on_tab_bar_mouse_exited() -> void:
	if selection > -1:
		central_node.holdMakeBuilding(selection)
		selection = -1
