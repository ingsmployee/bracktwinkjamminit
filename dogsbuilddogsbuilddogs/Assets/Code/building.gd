extends Node2D

var mouse_hovered: bool = false
var highlight: bool = false
var buildings_touched: Array[Node2D]
var prox_bonus_amount: Array[float] = [0,0,0]
@export_enum("Fun", "Safe", "Industry") var prox_bonus_type: int = 0
## number that is added to other buildings' thingies
@export var prox_bonus_addition: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_primary") && mouse_hovered && get_parent().get_parent().placement == null:
		var tween = get_tree().create_tween()
		tween.tween_property($"highlight areas", "modulate", Color(1,1,1,1), 0.3)
		print(prox_bonus_amount)

func _on_area_2d_building_mouse_entered() -> void:
	mouse_hovered = true

func place() -> void:
	$Sprite2D.self_modulate = Color(1,1,1,1)
	prox_bonus_amount = [0,0,0]
	for building in buildings_touched:
		building.get_node("Sprite2D").self_modulate = Color(1,1,1,1)
		building.prox_bonus_amount[prox_bonus_type] += prox_bonus_addition
		prox_bonus_amount[building.prox_bonus_type] += building.prox_bonus_addition

func remove() -> void:
	$AnimationPlayer.play("on_destroy")
	for building in buildings_touched:
		building.prox_bonus_amount[prox_bonus_type] -= prox_bonus_addition

func _on_area_2d_building_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)
	mouse_hovered = false


func _on_proximity_bonus_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().get_node("Sprite2D").self_modulate = Color(0.5,1,0.5,1)
	if area.get_parent() != self:
		buildings_touched.append(area.get_parent())


func _on_proximity_bonus_area_2d_area_exited(area: Area2D) -> void:
	area.get_parent().get_node("Sprite2D").self_modulate = Color(1,1,1,1)
	buildings_touched.erase(area.get_parent())
