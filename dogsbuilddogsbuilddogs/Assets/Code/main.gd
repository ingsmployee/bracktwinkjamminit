extends Node2D

var last_mouse_position
## note that increasing min zoom will decrease how much you can zoom out
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 5
## amount of zoom to add or remove when using the scroll wheel
const ZOOM_AMOUNT: float = 0.5


var buildingScenes: Array[PackedScene] = [
	preload("res://Assets/Scenes/Buildings/fun_tennis_ball.tscn")
	# put the other building scenes here.
]

var placement: Node2D
var is_placing: bool = false
var last_hovered_building: Node2D

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
	
	if Input.is_action_just_pressed("build_a"):
		placement = buildingScenes[0].instantiate()
		$buildings.add_child(placement)
		placement.get_node("Area2DBuilding").mouse_entered.connect(_mouse_entered.bind(placement))
		placement.get_node("Area2DBuilding").mouse_exited.connect(_mouse_exited.bind(placement))
		last_hovered_building = placement
	
	if Input.is_action_pressed("mouse_primary") && placement != null:
		# note that there are separate layers for proximity benefit areas and building collision boxes
		if !placement.get_node("Area2DBuilding").get_overlapping_areas():
			var player: AnimationPlayer = placement.get_node("AnimationPlayer")
			player.queue("on_placed")
			placement = null
		else:
			var player: AnimationPlayer = placement.get_node("AnimationPlayer")
			if !player.get_queue().has("flash_red_warning"):
				player.queue("flash_red_warning")
	
	if Input.is_action_just_pressed("mouse_secondary") && last_hovered_building != null:
		last_hovered_building.get_node("AnimationPlayer").play("on_destroy")
		last_hovered_building = null
		placement = null
	
	if (placement):
		placement.global_position = get_global_mouse_position()



func _mouse_entered(sender: Node2D):
	if !placement:
		last_hovered_building = sender
		sender.get_node("AnimationPlayer").queue("fade_in_areas")
	print("entered")

func _mouse_exited(sender: Node2D):
	if !placement:
		var player: AnimationPlayer = sender.get_node("AnimationPlayer")
		if player.is_playing():
			if player.current_animation != "fade_in_areas":
				player.advance(5)
		player.play("fade_out_areas")
	
	print("exited")
