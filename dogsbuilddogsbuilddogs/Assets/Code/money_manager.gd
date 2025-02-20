extends Node2D

var resources: Dictionary = {}
var building_type_amounts: Array[int] = [0,0,0]
var chance_of_bad: float = 0.1
var ui := UI.new()

# will prolly drag perf when receiving a bunch of requests but whateverrrr
func add_resource(resource_name: String, amount: float):
	if !resources.has(resource_name):
		resources[resource_name] = amount
	else:
		resources[resource_name] += amount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var textResult: String = "| Resources:\n"
	for key in resources.keys():
		textResult += ("| %s: %06.1f\n" % [key, resources[key]])
	$%"UI Resource Display".text = textResult
	

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
