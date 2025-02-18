extends Node2D

var desired_mouse_position: Vector2 = Vector2(0,0)
var original_camera_position: Vector2 = Vector2(0,0)
## note that increasing min zoom will decrease how much you can zoom out
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 5
## amount of zoom to add or remove when using the scroll wheel
const ZOOM_AMOUNT: float = 0.5


@export var buildingScenes: Array[PackedScene] = [
	preload("res://Assets/Scenes/Buildings/fun_tennis_ball.tscn"),
	preload("res://Assets/Scenes/Buildings/evil_factory_1.tscn")
]

var placement: Node2D
var is_placing: bool = false
var hovered_building: Node2D
var buildings_hovered_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	## scuffed. Input.get_blah blah blah only measures it every 0.1s 
	if Input.is_action_pressed("camera_pan"):
		$Camera2D.position -= (Input.get_last_mouse_velocity() * 1 / $Camera2D.zoom) * delta
	
	# previous attempt to fix pan. my brain's not working
	"""
	if Input.is_action_just_pressed("camera_pan"):
		desired_mouse_position = get_global_mouse_position()
		original_camera_position = $Camera2D.position
	if Input.is_action_pressed("camera_pan"):
		$Camera2D.position = get_global_mouse_position() - desired_mouse_position"""
	
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
	
	if Input.is_action_just_pressed("build_a") && placement == null:
		holdMakeBuilding(0)
	
	if Input.is_action_pressed("mouse_primary") && placement != null:
		# note that there are separate layers for proximity benefit areas and building collision boxes
		if !placement.get_node("Area2DBuilding").get_overlapping_areas():
			placement.global_position = gridify(get_global_mouse_position())
			var player: AnimationPlayer = placement.get_node("AnimationPlayer")
			placement.get_node("Sprite2D").position = placement.position
			$Tilemaps/WhiteOverlay.clear()
			player.queue("on_placed")
			placement.place()
			placement = null
		else:
			var player: AnimationPlayer = placement.get_node("AnimationPlayer")
			if !player.get_queue().has("flash_red_warning"):
				player.queue("flash_red_warning")
	
	if Input.is_action_just_pressed("mouse_secondary") && hovered_building != null:
		hovered_building.remove()
		hovered_building = null
		placement = null
	
	if (placement):
		var mouse_position: Vector2 = get_global_mouse_position()
		var grid_position: Vector2i = $Tilemaps/WhiteOverlay.local_to_map(mouse_position)
		$Tilemaps/WhiteOverlay.clear()
		$Tilemaps/WhiteOverlay.set_cell(grid_position, 0, Vector2i(0,0))
		var local_position: Vector2 = $Tilemaps/WhiteOverlay.map_to_local(grid_position)
		placement.global_position = local_position
		placement.get_node("Sprite2D").global_position = placement.get_node("Sprite2D").global_position.lerp(local_position, 0.2)

## give it a local position, it will spit out a position centered in that tilemap cell
func gridify(pos: Vector2) -> Vector2:
	return $Tilemaps/WhiteOverlay.map_to_local($Tilemaps/WhiteOverlay.local_to_map(pos))

func holdMakeBuilding(int) -> void:
	placement = buildingScenes[int].instantiate()
	$buildings.add_child(placement)
	placement.get_node("Area2DBuilding").mouse_entered.connect(_mouse_entered.bind(placement))
	placement.get_node("Area2DBuilding").mouse_exited.connect(_mouse_exited.bind(placement))
	placement.get_node("Sprite2D").modulate = Color(1,1,1,0.5)
	
	
	hovered_building = placement

func _mouse_entered(sender: Node2D) -> void:
	if !placement:
		hovered_building = sender
	buildings_hovered_count += 1

func _mouse_exited(sender: Node2D) -> void:
	buildings_hovered_count -= 1
	
	if buildings_hovered_count == 0:
		hovered_building = null
