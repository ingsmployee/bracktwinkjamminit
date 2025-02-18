extends Node2D

var last_mouse_position
## note that increasing min zoom will decrease how much you can zoom out
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 5
## amount of zoom to add or remove when using the scroll wheel
const ZOOM_AMOUNT: float = 0.5


@export var buildingScenes: Array[PackedScene] = [
	preload("res://Assets/Scenes/Buildings/fun_tennis_ball.tscn")
	# put the other building scenes here.
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
		placement = buildingScenes[0].instantiate()
		$buildings.add_child(placement)
		placement.get_node("Area2DBuilding").mouse_entered.connect(_mouse_entered.bind(placement))
		placement.get_node("Area2DBuilding").mouse_exited.connect(_mouse_exited.bind(placement))
		hovered_building = placement
	
	if Input.is_action_pressed("mouse_primary") && placement != null:
		# note that there are separate layers for proximity benefit areas and building collision boxes
		if !placement.get_node("Area2DBuilding").get_overlapping_areas():
			var player: AnimationPlayer = placement.get_node("AnimationPlayer")
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
		placement.global_position = get_global_mouse_position()



func _mouse_entered(sender: Node2D) -> void:
	if !placement:
		hovered_building = sender
	buildings_hovered_count += 1

func _mouse_exited(sender: Node2D) -> void:
	buildings_hovered_count -= 1
	
	if buildings_hovered_count == 0:
		hovered_building = null
