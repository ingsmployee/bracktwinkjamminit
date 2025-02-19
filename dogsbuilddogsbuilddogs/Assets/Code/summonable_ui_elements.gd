extends Resource
class_name UI

@export var elements_scenes: Dictionary = {
	"progress_bar": preload("res://assets/scenes/ui_elements/progress_bar.tscn"),
	"progress_circle": preload("res://assets/scenes/ui_elements/progress_circle.tscn"),
	
}

func get_new_element(id: String) -> Control: 
	var element = elements_scenes[id].instantiate()
	return element
