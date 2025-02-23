extends Node

var resource_types: Array[String] = ["money", "dogs", "lava"]
var _resources: Dictionary


var buildings: Array[BuildingStats] = [
	preload("res://assets/misc/buildings_stats/factory_1.tres"),
	preload("res://assets/misc/buildings_stats/tennis_ball_house.tres")
]

## [name, PackedScene]
var building_scenes: Dictionary

var alives: Array[PackedScene] = [
	preload("res://assets/scenes/alive/assistant.tscn")
]

func _ready() -> void:
	# we have less than 12 hours
	for building_stat in buildings:
		building_scenes[building_stat.building_name] = load(building_stat.building_scene)
	
	print(building_scenes)
	for resource in resource_types:
		_resources[resource] = 0
	_resources["money"] = 100

func get_resource(resource_name: String) -> float:
	return _resources[resource_name]

func set_resource(resource_name: String, value: float) -> void:
	_resources[resource_name] = value

func get_resource_dict() -> Dictionary:
	return _resources

func add_resource(resource_name: String, amount:float) -> void:
	_resources[resource_name] += amount

func subtract_resource(resource_name: String, amount:float) -> void:
	_resources[resource_name] -= amount

func add_resource_dict(resource_dict: Dictionary) -> void:
	for resource_name in resource_dict.keys():
		add_resource(resource_name, resource_dict[resource_name])

func subtract_resource_dict(resource_dict: Dictionary) -> void:
	for resource_name in resource_dict.keys():
		subtract_resource(resource_name, resource_dict[resource_name])
