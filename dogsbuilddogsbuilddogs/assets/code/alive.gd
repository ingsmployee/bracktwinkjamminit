extends Node2D

# todo:
# add stuff that works with AliveStuff (alives_manager.gd) to make ourselves available for navigation or something
# make navigation look way better. have it be based on velocity, maybe figure out how to add path variance, maybe create a waypoints system...
var target_building: Node2D
var home_building: Node2D
var velocity: float = 0 # single number because it will only move along the path??

var energy: float = 100
var resting: bool = true
var idle: bool = true
var speed_boost: float = 0

## this is not the maximum wandering distance. it is how far the animal can wander in one cycle.
# also while it is a circle it doesn't really have equal weights. this is because square
const WANDER_RADIUS: int = 1000

const TELEPORT_DISTANCE:float = 20
const MAX_MOVE_SPEED: float = 800 # pixels per second, scales with energy down to 70% movespeed at 70% energy
const MAX_ACCELERATION: float = 50
var current_move_speed: float = 0

func _raedy() -> void:
	wander()

func _process(delta:float) -> void:
	if resting:
		energy = max(0, energy)
		energy += delta * 5
		if energy >= 100:
			energy = 100
			resting = false
			leave_building()
	


func _physics_process(delta: float) -> void:
	if target_building or idle:
		
		# if we're already there, teleport. if we're not, use the movement system
		if ($NavigationAgent2D.get_final_position() == $NavigationAgent2D.get_next_path_position()) && (($NavigationAgent2D.get_final_position() - global_position).length() < TELEPORT_DISTANCE):
			global_position = $NavigationAgent2D.get_final_position()
			current_move_speed = 0
		else:
			var displacement: Vector2 = ($NavigationAgent2D.get_next_path_position() - global_position)
			current_move_speed += min(MAX_MOVE_SPEED - current_move_speed, MAX_ACCELERATION, 0.3 * (MAX_MOVE_SPEED - current_move_speed)) + 5
			var move_vector: Vector2 = displacement.normalized() * current_move_speed * min(displacement.length() * 10, 1)
			
			$Sprite2D.flip_h = move_vector.x > 0
			speed_boost = move_toward(speed_boost, 0, 0.1 * delta)
			global_position += move_vector * delta * (1 + speed_boost)
	

func remove() -> void:
	get_parent().ready_alives.erase(self)
	if target_building:
		target_building.emit_signal("make_self_available")
		target_building = null
	queue_free()

func make_self_ready() -> void:
	idle = true
	wander()
	target_building = null
	get_parent().add_ready_alive(self)

var oops_building_deleted: bool = true
func finished_last_task() -> void:
	if !oops_building_deleted && target_building && target_building.stats.request_animals:
		get_tree().create_tween().tween_callback(target_building.emit_signal.bind("make_self_available")).set_delay(target_building.stats.interact_time / (1 + 0.5 * target_building.prox_bonus_amount[1]))
	else:
		oops_building_deleted = false
	target_building = null
	if energy < 10:
		go_to_building(home_building)
	else:
		make_self_ready()

var wander_wait_tween: Tween
func _on_navigation_agent_2d_navigation_finished() -> void:
	if idle:
		if wander_wait_tween:
			wander_wait_tween.kill()
		wander_wait_tween = get_tree().create_tween()
		wander_wait_tween.tween_callback(wander).set_delay($"..".random.randi_range(3,7))
	else:
		enter_building(target_building)

func wander():
	energy -= 5
	$NavigationAgent2D.target_position = position + Vector2($"..".random.randi_range(-WANDER_RADIUS, WANDER_RADIUS), $"..".random.randi_range(-WANDER_RADIUS, WANDER_RADIUS)).normalized() * WANDER_RADIUS

func go_to_building(building: Node2D) -> void:
	idle = false
	if wander_wait_tween:
		wander_wait_tween.kill()
	target_building = building
	building.tree_exiting.connect(oops_building_was_deleted)
	$NavigationAgent2D.target_position = building.get_node("DoggyDoor").global_position

var in_building: bool
func enter_building(building: Node2D) -> void:
	in_building = true
	building.animal_interact(self)
	$AnimationPlayer.play("enter_building")
	
	if target_building == home_building: # if we're going home, we leave when we're rested
		resting = true
		return
	
	# if we're going somewhere else, stay in there for however long it takes and modify energy
	var tween = get_tree().create_tween()
	tween.tween_callback(leave_building).set_delay(target_building.stats.interact_time / (1 + speed_boost))
	var energy_change: float = target_building.stats.interact_energy_change
	if energy_change < 0:
		energy += energy_change * ((1 / ((target_building.prox_bonus_amount[0]/3) + 0.5)) - 0.2)
	else:
		energy += energy_change + (target_building.prox_bonus_amount[0] * 3)
	
	if target_building.stats.risk > 0:
		if RandomNumberGenerator.new().randi_range(0, 10) <= target_building.stats.risk:
			energy = 0.3 * energy

func leave_building() -> void:
	in_building = false
	if target_building && !oops_building_deleted:
		target_building.tree_exiting.disconnect(oops_building_was_deleted)
	$AnimationPlayer.play("exit_building")
	finished_last_task()

func oops_building_was_deleted() -> void:
	oops_building_deleted = true
	leave_building()
