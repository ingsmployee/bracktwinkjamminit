extends Node

## this is where you wanna add new sounds
var sfx: Dictionary = {
	"button_pressed": preload("res://assets/sounds/click.wav"),
	"woosh": preload("res://assets/sounds/woosh.wav")
}

# {bus_name: String, [AudioStreamPlayer, AudioStreamPlaybackPolyphonic]}
var players: Dictionary

func _ready():
	newPlayer("UI Sounds")

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
