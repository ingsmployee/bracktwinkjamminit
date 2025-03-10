extends Node2D

## README when you place the building,
# you must set main_node as the main Node
# and connect the rebake_navmap signal to it
# also connect the make_self_available signal to AlivesManager

# if you don't give NavigationBarrier a collision_shape, it will copy Area2DBuilding's.
# don't put too much navigation in here besides something like "hey! we're available!", AliveStuff should handle actual nav orders

@export var stats: BuildingStats

var selected
var highlightCopy: Sprite2D
var buildings_touched: Array[Node2D]
var prox_bonus_amount: Array[float] = [0,0,0]

var main_node: Node2D
var progress_bar: TextureProgressBar
var ui: UI = UI.new()

var production_progress: float = 0
@onready var production_multiplier: float = stats.baseline_production_multiplier
@onready var speed_multiplier: float = stats.baseline_speed_multiplier

var placed: bool = false

var housed_dogs: Array[Node2D]

signal rebake_navmap
signal make_self_available

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $NavigationBarrier.get_child_count() == 0:
		for child in $Area2DBuilding.get_children():
			print(child)
			$NavigationBarrier.add_child(child.duplicate())

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
		match stats.building_type:
			0: # if this is a fun building
				pass
			1: # if this is a safe building
				pass
			2: # if this is a factory
				production_progress += delta * speed_multiplier
				if production_progress > stats.production_time:
					var productions:int = floor(production_progress / stats.production_time)
					produce(productions * production_multiplier)
					production_progress -= productions * stats.production_time
					if progress_bar != null:
						var tween = get_tree().create_tween()
						progress_bar.tint_progress = Color(1,1,1,0)
						tween.tween_property(progress_bar, "tint_progress", Color(1,1,1,1),0.2).set_ease(Tween.EASE_OUT)
				
				if progress_bar != null:
					progress_bar.value = (production_progress / stats.production_time) * (progress_bar.max_value - progress_bar.min_value) + progress_bar.min_value
		
		# still if placed
		
	
	

func animal_interact(animal: Node2D):
	match stats.building_type:
		0:
			pass
		1:
			animal.speed_boost += 0.5
			animal.energy += 5
		2:
			produce(5 * prox_bonus_amount[1])

func produce(amount: float) -> void:
	GameResources.add_resource_dict(stats.production_result)
	GameResources.subtract_resource_dict(stats.production_cost)

func update_modifiers() -> void:
	# production multiplier benefits from having Fun around
	production_multiplier = (0.2 * log(prox_bonus_amount[0] + 1) + 1) * stats.baseline_production_multiplier
	speed_multiplier = (0.2 * log(prox_bonus_amount[stats.building_type] + 1) + 1) * stats.baseline_speed_multiplier 
	

func set_selected(input: bool) -> void:
	selected = input
	if input:
		var tween = get_tree().create_tween()
		tween.tween_property($"highlight areas", "modulate", Color(1,1,1,1), 0.3)
		$Sprite2D.z_index = 3
		
		if stats.building_type == 2:
			pass
			#progress_bar = ui.get_new_element("progress_bar")
			#$LocalUI.add_child(progress_bar)
			#progress_bar.global_position = global_position - 0.5 * (progress_bar.scale * progress_bar.size) +  100 * Vector2.UP
			#progress_bar.get_node("Label").text = "Fun: %3.01f Safety: %3.01f Industry: %3.01f" % prox_bonus_amount
	else:
		$Sprite2D.z_index = 1
		var tween = get_tree().create_tween()
		tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)
		if progress_bar:
			progress_bar.queue_free()
			progress_bar = null

func place() -> void:
	GameResources.subtract_resource_dict(stats.cost)
	$Sprite2D.top_level = false
	$Sprite2D.position = Vector2(0,0)
	$Sprite2D.y_sort_enabled = true
	$Sprite2D.self_modulate = Color(1,1,1,1)
	$Sprite2D.z_index = 2
	prox_bonus_amount = [0,0,0]
	get_parent().building_type_amounts[stats.building_type] += 1
	placed = true
	rebake_navmap.emit()
	if stats.request_animals:
		make_self_available.emit()
	for building in buildings_touched:
		building.get_node("Sprite2D").self_modulate = Color(1,1,1,1)
		building.prox_bonus_amount[stats.building_type] += stats.prox_bonus_addition
		prox_bonus_amount[building.stats.building_type] += building.stats.prox_bonus_addition
		building.update_modifiers()
	
	var tween = get_tree().create_tween()
	tween.tween_property($"highlight areas", "modulate", Color(1,1,1,0), 0.3)
	$Sprite2D.z_index = 1
	update_modifiers()
	

var on_death_row: bool = false
func remove() -> void:
	if on_death_row:
		return
	on_death_row = true
	GameResources.add_resource("money", stats.cost["money"] * 0.7) # return 70% of money back
	for animal in housed_dogs:
		animal.remove()
	$"../../AlivesManager".ready_buildings.erase(self)
	
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", $Sprite2D.scale * 0.2, 0.5).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_EXPO)
	$NavigationBarrier.queue_free()
	$AnimationPlayer.play("on_destroy")
	get_parent().building_type_amounts[stats.building_type] -= 1
	if placed:
		for building in buildings_touched:
			building.prox_bonus_amount[stats.building_type] -= stats.prox_bonus_addition
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
