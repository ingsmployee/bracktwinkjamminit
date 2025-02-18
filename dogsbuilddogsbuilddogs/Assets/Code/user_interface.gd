extends Control

@export var central_node: Node2D

var selection: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_tab_bar_tab_clicked(tab: int) -> void:
	selection = tab


func _on_tab_bar_mouse_exited() -> void:
	if selection > -1:
		central_node.holdMakeBuilding(selection)
		selection = -1
