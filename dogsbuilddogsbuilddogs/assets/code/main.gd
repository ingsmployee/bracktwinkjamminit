extends Node2D

var desired_mouse_position: Vector2 = Vector2(0,0)
var original_camera_position: Vector2 = Vector2(0,0)
## note that increasing min zoom will decrease how much you can zoom out
const MIN_ZOOM: float = 0.2
const MAX_ZOOM: float = 0.7
## amount of zoom to add or remove when using the scroll wheel
const ZOOM_AMOUNT: float = 0.5

var placement: Node2D
var trying_to_place: bool = false
var attempted_placement_position: Vector2
var hovered_building: Node2D
var buildings_hovered_count: int = 0

# i ammmm 90% sure that hovered_building is mostly useless and should be replaced
# with a system dependent on signals if theres any desirable features it even has
# the white overlay grid thing when building also stopped working a while ago. probably because i deleted a part of it
# last comment for today (2/21) (just walked through some of the scripts). im going to sleep now lol


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	# 2 hours before due date. i don't even know at this point.
	
	# maybe we should move "you can't build here!" detection to the buildings themselves?? idk lmfao
	if event is InputEventMouseButton && event.pressed == true && placement != null:
		# note that there are separate layers for proximity benefit areas and building collision boxes
		trying_to_place = true
		attempted_placement_position = gridify(get_global_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# what you are about to see is some of the first code i wrote on this project
	# after not using godot for months.
	# prepare your PPE as i have since then not altered any of it
	## scuffed. Input.get_blah blah blah only measures it every 0.1s 
	#if Input.is_action_pressed("pan_up"):
		#$Camera2D.get_target_position()
	
	$Camera2D.global_position += Vector2(Input.get_axis("pan_left", "pan_right"), Input.get_axis("pan_up", "pan_down")) * delta * 1000 / $Camera2D.zoom
	
	
	# AAAAHHHHHH
	if Input.is_action_just_pressed("mouse_wheel_down"):
		var tween: Tween = get_tree().create_tween()
		tween.tween_property($Camera2D, "zoom", Vector2(
			clamp($Camera2D.zoom.x / (1+ZOOM_AMOUNT), MIN_ZOOM, MAX_ZOOM), 
			clamp($Camera2D.zoom.y / (1+ZOOM_AMOUNT), MIN_ZOOM, MAX_ZOOM)),
			0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	elif Input.is_action_just_pressed("mouse_wheel_up"):
		var tween: Tween = get_tree().create_tween()
		tween.tween_property($Camera2D, "zoom", Vector2(
			clamp($Camera2D.zoom.x * (1+ZOOM_AMOUNT), MIN_ZOOM, MAX_ZOOM), 
			clamp($Camera2D.zoom.y * (1+ZOOM_AMOUNT), MIN_ZOOM, MAX_ZOOM)),
			0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	
	
	
	
	if (placement):
		var mouse_position: Vector2 = get_global_mouse_position()
		var grid_position: Vector2i = $Tilemaps/Grass.local_to_map(mouse_position)
		var local_position: Vector2 = $Tilemaps/Grass.map_to_local(grid_position)
		placement.global_position = local_position
		placement.get_node("Sprite2D").global_position = (placement.get_node("Sprite2D").global_position).lerp(local_position, 0.2)

func _physics_process(delta: float) -> void:
	if trying_to_place:
		placement.global_position = attempted_placement_position
		#print(placement.get_node("Area2DBuilding").get_overlapping_bodies() , placement.get_node("Area2DBuilding").get_overlapping_areas())
		
		if !(placement.get_node("Area2DBuilding").get_overlapping_bodies() or placement.get_node("Area2DBuilding").get_overlapping_areas()):
			trying_to_place = false
			place_held_building()
		else:
			trying_to_place = false
			var player: AnimationPlayer = placement.get_node("AnimationPlayer")
			if !player.get_queue().has("flash_red_warning"):
				player.queue("flash_red_warning")

## give it a local position, it will spit out a position centered in that tilemap cell
func gridify(pos: Vector2) -> Vector2:
	return $Tilemaps/Grass.map_to_local($Tilemaps/Grass.local_to_map(pos))

func hold_make_building(building_scene: PackedScene) -> void:
	if placement:
		placement.remove()
	placement = building_scene.instantiate()
	$Buildings.add_child(placement)
	placement.get_node("Area2DBuilding").mouse_entered.connect(_mouse_entered.bind(placement))
	placement.get_node("Area2DBuilding").mouse_exited.connect(_mouse_exited.bind(placement))
	placement.get_node("Sprite2D").modulate = Color(1,1,1,0.5)
	placement.main_node = self
	placement.rebake_navmap.connect($%NavigationRegion2D.bake_new_navmap)
	placement.tree_exited.connect($%NavigationRegion2D.bake_new_navmap)
	placement.make_self_available.connect($%AlivesManager.make_building_available.bind(placement))
	
	hovered_building = placement

# it's in the name
func place_held_building() -> void:
	placement.global_position = attempted_placement_position
	# sprite position will be handled by placement.place()
	
	#print("placement placed at %s from %s" % [placement.global_position, get_global_mouse_position()])
	
	placement.get_node("AnimationPlayer").queue("on_placed")
	# spawn animals
	for i in range(0, placement.stats.housing_space):
		placement.housed_dogs.append($AlivesManager.instantiate_random_from_building(placement))
	placement.place()
	placement = null

func _mouse_entered(sender: Node2D) -> void:
	if !placement:
		hovered_building = sender
	buildings_hovered_count += 1

func _mouse_exited(sender: Node2D) -> void:
	buildings_hovered_count -= 1
	
	if buildings_hovered_count == 0:
		hovered_building = null
