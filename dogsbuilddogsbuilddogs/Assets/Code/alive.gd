extends Node2D

#func go_random() -> void:
	#var random := RandomNumberGenerator.new()
	#
	#
	#$NavigationAgent2D.target_position = Vector2(random.randi_range(-1000,1000), random.randi_range(-1000,1000))
	#print("Going to %s!" % $NavigationAgent2D.target_position)
#
#func _process(delta: float) -> void:
	#pass
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	#print("happening")
	#if $NavigationAgent2D.is_navigation_finished():
		#go_random()
	#else:
		#global_position = $NavigationAgent2D.get_next_path_position()
		

func _process(delta:float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("build_b"):
		$NavigationAgent2D.target_position = get_global_mouse_position()
		# print("Going to %s!" % $NavigationAgent2D.target_position)
		# print($NavigationAgent2D.get_next_path_position())

func _physics_process(delta: float) -> void:
	var desired_position = global_position - $NavigationAgent2D.get_next_path_position()
	global_position -= desired_position.normalized() * min(desired_position.length(), 3)
