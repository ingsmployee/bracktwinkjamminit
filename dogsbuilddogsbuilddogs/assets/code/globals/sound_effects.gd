extends Node

@onready var random := RandomNumberGenerator.new()

## this is where you wanna add new sounds
var sfx: Dictionary = {
	"button_pressed": preload("res://assets/sounds/click.wav"),
	"woosh": preload("res://assets/sounds/woosh.wav"),
	"mumble_1": preload("res://assets/sounds/mumble_a.wav"),
	"mumble_2": preload("res://assets/sounds/mumble_b.wav"),
	"mumble_3": preload("res://assets/sounds/mumble_c.wav"),
	"meow": preload("res://assets/sounds/mrow.wav")
}

# {bus_name: String, [AudioStreamPlayer, AudioStreamPlaybackPolyphonic]}
var players: Dictionary

func _ready():
	newPlayer("UI Sounds")
	newPlayer("Music")
	newPlayer("Ingame SFX")

func newPlayer(bus_name: String) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	player.name = bus_name
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 10
	player.stream = stream
	add_child(player)
	player.play()
	players[bus_name] = [player, player.get_stream_playback()]

func play(sound_name: String, bus_name: StringName) -> void:
	var player = players[bus_name][0]
	if !player.playing: player.play()
	players[bus_name][1].play_stream(sfx[sound_name])

func play_dialog_start(input: String):
	if input == "cat":
		play("meow", "Ingame SFX")
	else:
		play("mumble_%s" % random.randi_range(1,3), "Ingame SFX")
