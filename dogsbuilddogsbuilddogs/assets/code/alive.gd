extends Node2D

# todo:
# add stuff that works with AliveStuff (alives_manager.gd) to make ourselves available for navigation or something
# make navigation look way better. have it be based on velocity, maybe figure out how to add path variance, maybe create a waypoints system...
var target_building: Node2D
var home_building: Node2D
var velocity: float = 0 # single number because it will only move along the path??

var energy: float = 100
var resting: bool = true

const ACCELERATION: float = 5
@export var max_velocity: float = 3

func _process(delta:float) -> void:
	if resting:
		energy = max(0, energy)
		energy += delta * 100
		if energy >= 100:
			energy = 100
			resting = false
			leave_building()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("build_b"):
		# note that this type of thing is literally all you have to do to find a path
		$NavigationAgent2D.target_position = get_global_mouse_position()
		# print("Going to %s!" % $NavigationAgent2D.target_position)
		# print($NavigationAgent2D.get_next_path_position())

func _physics_process(delta: float) -> void:
	if target_building:
		var desired_position = global_position - $NavigationAgent2D.get_next_path_position()
		global_position -= desired_position.normalized() * min(desired_position.length(), 3) * 500 * delta

func go_to_building(building: Node2D) -> void:
	target_building = building
	$NavigationAgent2D.target_position = building.position

func make_self_ready() -> void:
	target_building = null
	get_parent().add_ready_alive(self)

func finished_last_task() -> void:
	target_building.emit_signal("make_self_available")
	if energy < 10:
		target_building = home_building
	else: 
		make_self_ready()

func remove() -> void:
	if target_building:
		target_building.emit_signal("make_self_available")
		target_building = null
	queue_free()

func _on_navigation_agent_2d_navigation_finished() -> void:
	if (($NavigationAgent2D.target_position - position).length() < 20): # then we have reached the target
		enter_building(target_building)
	else:
		make_self_ready()

func enter_building(building: Node2D) -> void:
	building.animal_interact(self)
	hide()
	
	if target_building == home_building: # if we're going home, we leave when we're rested
		resting = true
		return
	
	# if we're going somewhere else, stay in there for however long it takes and modify energy
	var tween = get_tree().create_tween()
	tween.tween_callback(leave_building).set_delay(target_building.stats.interact_time)
	var energy_change: float = target_building.stats.interact_energy_change
	if energy_change < 0:
		energy += energy_change * ((1 / ((target_building.prox_bonus_amount[0]/3) + 0.5)) - 0.2)
	else:
		energy += energy_change + (target_building.prox_bonus_amount[0] * 3)
	
	if target_building.stats.risk > 0:
		if RandomNumberGenerator.new().randi_range(0, 10) <= target_building.stats.risk:
			energy = 0.3 * energy
	
	

func leave_building() -> void:
	show()
	finished_last_task()
