extends Node

var resource_types: Array[String] = ["money", "dogs", "lava", "wood", "energy"]
var _resources: Dictionary

## [name, PackedScene]
var buildingScenes: Dictionary = {
	"tennis_ball": preload("res://assets/scenes/buildings/fun_1.tscn"),
	"resource_collector": preload("res://assets/scenes/buildings/factory_1.tscn"),
}

func _ready() -> void:
	for resource in resource_types:
		_resources[resource] = 0
		

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
