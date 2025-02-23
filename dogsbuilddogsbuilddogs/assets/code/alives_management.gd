extends Node2D

var alives: Array[PackedScene] = GameResources.alives

var random := RandomNumberGenerator.new()

var ready_alives: Array[Node2D]
var ready_buildings: Array[Node2D]

# todo:
# make a navigation ordering system, where we can send dogs to random places or something.
# just get them moving lol


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	pass

func add_ready_alive(alive: Node2D) -> void:
	ready_alives.append(alive)

func instantiate_random_from_building(home_building: Node2D) -> Node2D:
	var newborn = alives[random.randi_range(0,alives.size()-1)].instantiate()
	add_child(newborn)
	newborn.home_building = home_building
	newborn.target_building = home_building
	newborn.position = home_building.get_node("DoggyDoor").global_position
	# note that all newborns are considered "resting" to start with
	newborn.hide()
	newborn.energy = 90
	return newborn

func send_random_ready_alive() -> void:
	var index: int = random.randi_range(0, max(0, ready_alives.size()-1))
	var alive = ready_alives[index]
	
	ready_alives.remove_at(index)
	
	index = random.randi_range(0, max(0, ready_buildings.size()-1))
	var building = ready_buildings[index]
	ready_buildings.remove_at(index)
	
	alive.go_to_building(building)

func make_building_available(building: Node2D) -> void:
	ready_buildings.append(building)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(0, min(ready_alives.size(), ready_buildings.size())):
		send_random_ready_alive()
