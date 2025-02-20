extends Node2D

var alives: Array[PackedScene] = [
	preload("res://assets/scenes/alive/dog_template.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("build_a"):
		var newborn = alives[0].instantiate()
		add_child(newborn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
