extends Node2D

const BUILDING_TYPES: int = 3

var selected
var highlightCopy: Sprite2D
var buildings_touched: Array[Node2D]
var prox_bonus_amount: Array[float] = [0,0,0]

var main_node: Node2D
var progress_bar: TextureProgressBar
var ui: UI = UI.new()

var progress: float = 0
var destination: int = 10
@export var baseline_production_multiplier: float = 1
var production_multiplier: float = baseline_speed_multiplier
@export var baseline_speed_multiplier: float = 1
var speed_multiplier: float = baseline_speed_multiplier

var placed: bool = false
@export var building_name: String = "Placeholder"
@export_enum("Fun", "Safe", "Industry") var prox_bonus_type: int = 0
var resource_names: Array[String] = ["Fun", "Safe", "Industry"]

## number that is added to other buildings' thingies
@export var prox_bonus_addition: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_area_2d_building_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouse_primary") && main_node.placement == null:
		set_selected(not selected)
	elif event.is_action_pressed("mouse_secondary"):
		if !main_node.placement:
			remove()
		elif main_node.placement == self:
			main_node.placement = null
			main_node.hovered_building = null
			remove()
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_primary") && selected:
		set_selected(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if placed:
		match prox_bonus_type:
			1:
				pass
			2:
				progress += delta * speed_multiplier
				if progress > destination:
					var productions:int = floor(progress / destination)
					produce(productions * production_multiplier)
					progress -= productions * destination
					if progress_bar != null:
						var tween = get_tree().create_tween()
						progress_bar.tint_progress = Color(1,1,1,0)
						tween.tween_property(progress_bar, "tint_progress", Color(1,1,1,1),0.2).set_ease(Tween.EASE_OUT)
				
				if progress_bar != null:
					progress_bar.value = (progress / destination) * (progress_bar.max_value - progress_bar.min_value) + progress_bar.min_value
			3:
				pass
		
		

func produce(amount: float) -> void:
	get_parent().add_resource(resource_names[prox_bonus_type], amount)

func update_modifiers() -> void:
	production_multiplier = (0.2 * log(prox_bonus_amount[(prox_bonus_type+1) % BUILDING_TYPES] + 1) + 1) * baseline_production_multiplier
	speed_multiplier = (0.2 * log(prox_bonus_amount[prox_bonus_type] + 1) + 1) * baseline_speed_multiplier 
	

func set_selected(input: bool) -> void:
	selected = input
	if input:
		var tween = get_tree().create_tween()
		tween.tween_property($"highlight areas", "modulate", Color(1,1,1,1), 0.3)
		$Sprite2D.z_index = 3
		
		if prox_bonus_type == 2:
			progress_bar = ui.get_new_element("progress_bar")
			$LocalUI.add_child(progress_bar)
			progress_bar.global_position = global_position - 0.5 * (progress_bar.scale * progress_bar.size) +  100 * Vector2.UP
			progress_bar.get_node("Label").text = "Fun: %3.01f Safety: %3.01f Industry: %3.01f" % prox_bonus_amount
	else:
		$Sprite2D.z_index = 1
		var tween = get_tree().create_tween()
		tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)
		if progress_bar:
			progress_bar.queue_free()
			progress_bar = null

func place() -> void:
	$Sprite2D.self_modulate = Color(1,1,1,1)
	$Sprite2D.z_index = 1
	prox_bonus_amount = [0,0,0]
	placed = true
	for building in buildings_touched:
		building.get_node("Sprite2D").self_modulate = Color(1,1,1,1)
		building.prox_bonus_amount[prox_bonus_type] += prox_bonus_addition
		prox_bonus_amount[building.prox_bonus_type] += building.prox_bonus_addition
		building.update_modifiers()
	
	var tween = get_tree().create_tween()
	tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)
	$Sprite2D.z_index = 1
	update_modifiers()

func remove() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", $Sprite2D.scale * 0.2, 0.5).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_EXPO)
	$AnimationPlayer.play("on_destroy")
	if placed:
		for building in buildings_touched:
			building.prox_bonus_amount[prox_bonus_type] -= prox_bonus_addition
			building.update_modifiers()

func _on_proximity_bonus_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().get_node("Sprite2D").self_modulate = Color(0.5,1,0.5,1)
	if area.get_parent() != self:
		buildings_touched.append(area.get_parent())


func _on_proximity_bonus_area_2d_area_exited(area: Area2D) -> void:
	area.get_parent().get_node("Sprite2D").self_modulate = Color(1,1,1,1)
	buildings_touched.erase(area.get_parent())


func _on_area_2d_building_mouse_exited() -> void:
	pass
