extends Node2D

var highlighted: bool = false
var highlightCopy: Sprite2D
var buildings_touched: Array[Node2D]
var prox_bonus_amount: Array[float] = [0,0,0]

var progress: float = 0
var destination: float = 100

var placed: bool = false
@export_enum("Fun", "Safe", "Industry") var prox_bonus_type: int = 0
## number that is added to other buildings' thingies
@export var prox_bonus_addition: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var multiplier = 1
	if placed:
		if prox_bonus_type == 2:
			progress += delta * multiplier
		if progress > destination:
			var productions:int = floor(progress / destination)
			produce(productions)
			progress -= productions * destination

func produce(amount: int) -> void:
	print("Producing!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_primary") && get_parent().get_parent().placement == null:
		hide_circles()

func _on_area_2d_building_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouse_primary") && get_parent().get_parent().placement == null:
		show_circles()
		highlight()
		
		# for building in buildings_touched:
			# building.get_node("Sprite2D").self_modulate = Color(0.5,1,0.5,1)
		print(prox_bonus_amount)

func show_circles() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($"highlight areas", "modulate", Color(1,1,1,1), 0.3)
	
	# for building in buildings_touched:
		# building.get_node("Sprite2D").self_modulate = Color(0.5,1,0.5,1)
	print(prox_bonus_amount)

func hide_circles() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)

func highlight() -> void:
	$Sprite2D.z_index = 3
	highlighted = true

func unhighlight() -> void:
	$Sprite2D.z_index = 1
	highlighted = false

func place() -> void:
	$Sprite2D.self_modulate = Color(1,1,1,1)
	$Sprite2D.z_index = 1
	prox_bonus_amount = [0,0,0]
	placed = true
	for building in buildings_touched:
		building.get_node("Sprite2D").self_modulate = Color(1,1,1,1)
		building.prox_bonus_amount[prox_bonus_type] += prox_bonus_addition
		prox_bonus_amount[building.prox_bonus_type] += building.prox_bonus_addition
	
	var tween = get_tree().create_tween()
	tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)
	$Sprite2D.z_index = 1

func remove() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(0.2,0.2), 0.5).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_EXPO)
	$AnimationPlayer.play("on_destroy")
	if placed:
		for building in buildings_touched:
			building.prox_bonus_amount[prox_bonus_type] -= prox_bonus_addition

func _on_proximity_bonus_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().get_node("Sprite2D").self_modulate = Color(0.5,1,0.5,1)
	if area.get_parent() != self:
		buildings_touched.append(area.get_parent())


func _on_proximity_bonus_area_2d_area_exited(area: Area2D) -> void:
	area.get_parent().get_node("Sprite2D").self_modulate = Color(1,1,1,1)
	buildings_touched.erase(area.get_parent())
