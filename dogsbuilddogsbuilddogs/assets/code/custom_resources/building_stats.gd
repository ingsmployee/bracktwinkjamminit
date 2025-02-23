extends Resource
class_name BuildingStats

# this is not meant to store the path of the building. that should go in the GameResources singleton.


## The path of the building's scene, for populating shop entries.
@export var building_scene: String
## The building's icon, for populating shop entries.
@export var building_icon: Texture2D


## The displayed name of the building. Don't make it too long.
@export var building_name: String = "Amazing Building"
## Affects behavior and provided proximity benefit.
@export_enum("Fun", "Safe", "Industry") var building_type: int = 0
## Amount of proximity points provided to other buildings in the selected category.
@export var prox_bonus_addition: float = 1
## Factor of the building's contribution to non-environmental negative events.
@export var risk: float = 1
## The amount of dogs that can be housed in this building.
@export var housing_space: int = 0
## The cost to build one. Don't put more than 2 resource types.
@export var cost: Dictionary = {"money": 10, "lava": 0, "wood": 0, "energy": 0}
## How much the Bureaucats like this building.
@export var cat_appeasement: int = 1
## Added or subtracted from animals' energy when they interact with this building.
@export var interact_energy_change: float = 0

## Only relevant for Fun buildings.
@export_category("Fun buildings")
##
@export var fun_power: float = 1

## Only relevant for Safety buildings.
@export_category("Safe buildings")
## How good the building is at repairing and treating dogs.
@export var anti_disaster_power: float = 1

## Only relevant for Industry buildings.
# Industry buildings produce a resource, optionally 
@export_category("Factory buildings")
## The resources to be added to the inventory once the production cycle is completed.
@export var production_result: Dictionary = {"money": 1, "lava": 0}
## The resources to be removed from the inventory once the production cycle is completed.
@export var production_cost: Dictionary = {"money": 0, "lava": 0}
## The amount of the resource produced at the end of the production cycle, before proximity calculations.
@export var baseline_production_multiplier: float = 1
## The base time in seconds it takes to complete a production cycle. Modified by proximity and baseline_speed_multiplier.
@export var production_time: float = 10
## The speed factor of the production cycle, before proximity calculations.
@export var baseline_speed_multiplier: float = 1
