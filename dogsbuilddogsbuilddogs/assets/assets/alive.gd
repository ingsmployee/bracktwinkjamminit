extends Node2D

# todo:
# add stuff that works with AliveStuff (alives_manager.gd) to make ourselves available for navigation or something
# make navigation look way better. have it be based on velocity, maybe figure out how to add path variance, maybe create a waypoints system...

func _process(delta:float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("build_b"):
		# note that this type of thing is literally all you have to do to find a path
		$NavigationAgent2D.target_position = get_global_mouse_position()
		# print("Going to %s!" % $NavigationAgent2D.target_position)
		# print($NavigationAgent2D.get_next_path_position())

func _physics_process(delta: float) -> void:
	# note that get_next_path_position() has to do with navigating the current little slice we're in
	var desired_position = global_position - $NavigationAgent2D.get_next_path_position()
	global_position -= desired_position.normalized() * min(desired_position.length(), 3)
