extends Node2D

var resources: Dictionary = {}

# will prolly drag perf when receiving a bunch of requests but whateverrrr
func add_resource(resource_name: String, amount: float):
	if !resources.has(resource_name):
		resources[resource_name] = amount
	else:
		resources[resource_name] += amount


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var textResult: String = "| Resources:\n"
	for key in resources.keys():
		textResult += ("| %s: %06.1f\n" % [key, resources[key]])
	$%"UI Resource Display".text = textResult
