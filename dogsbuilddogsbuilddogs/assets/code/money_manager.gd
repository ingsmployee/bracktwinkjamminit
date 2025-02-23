extends Node2D

var building_type_amounts: Array[int] = [0,0,0]
var chance_of_bad: float = 0.1
var ui := UI.new()

# will prolly drag perf when receiving a bunch of requests but whateverrrr
func add_resource(resource_name: String, amount: float):
	GameResources.add_resource(resource_name, amount)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_building("Resource Extractor", Vector2i(0,0))
	#spawn_building("Tennis Ball House", Vector2i(-1, -3))

func spawn_building(building_name:String, location: Vector2i) -> Node2D:
	var building = GameResources.building_scenes[building_name].instantiate()
	add_child(building)
	building.position = $"../Tilemaps/Grass".map_to_local($"../Tilemaps/Grass".local_to_map(Vector2(0,0)))
	building.get_node("AnimationPlayer").queue("on_placed")
	building.main_node = $".."
	building.get_node("Area2DBuilding").mouse_entered.connect($".."._mouse_entered.bind(building))
	building.get_node("Area2DBuilding").mouse_exited.connect($".."._mouse_exited.bind(building))
	building.rebake_navmap.connect($%NavigationRegion2D.bake_new_navmap)
	building.tree_exited.connect($%NavigationRegion2D.bake_new_navmap)
	building.make_self_available.connect($%AlivesManager.make_building_available.bind(building))
	building.place()
	return building

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# i don't care anymore just make it work
func tryRandomEvent() -> void:
	var random := RandomNumberGenerator.new()
	if random.randf() < chance_of_bad:
		match random.randi_range(0,3):
			1:
				pass
			2:
				pass
			3:
				pass
	
	$%EventTimer.wait_time = round(clamp(random.randfn(7,1.1), 5, 12) * 10)
	$%EventTimer.start()


func _on_event_timer_timeout() -> void:
	tryRandomEvent()
