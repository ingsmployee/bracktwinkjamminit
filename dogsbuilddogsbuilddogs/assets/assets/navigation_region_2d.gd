extends NavigationRegion2D

var bounding_outline: PackedVector2Array
const outline_size: int = 500



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bounding_outline = PackedVector2Array([Vector2(0,0), Vector2(0,outline_size), Vector2(outline_size,outline_size), Vector2(outline_size,0)])
	bake_new_navmap.call_deferred()

# note that this function is connected to by buildings via signals
# aka dont change the name unless you go into main and change the connection there too
func bake_new_navmap() -> void:
	# i know
	# it bakes literally the entire map over again
	# i don't want to change it unless it starts causing problems
	bake_navigation_polygon()
	# print("Attempted to bake new thing")

var bake_time: int = 0
func _physics_process(delta: float) -> void:
	if is_baking():
		bake_time += 1
		if bake_time > 5:
			print("Navmesh baking is taking too long! (%s)" % bake_time)
	else:
		bake_time = 0
