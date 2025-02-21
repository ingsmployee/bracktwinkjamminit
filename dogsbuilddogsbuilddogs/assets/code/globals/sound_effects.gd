extends Node

## this is where you wanna add new sounds
var sfx: Dictionary = {
	"button_pressed": preload("res://assets/sounds/Pop sound effect.mp3")
}

var player: AudioStreamPlayer
var stream: AudioStreamPolyphonic
var playback: AudioStreamPlaybackPolyphonic

func _ready():
	player = AudioStreamPlayer.new()
	player.bus = "UI Sounds"
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 10
	player.stream = stream
	add_child(player)
	player.play()
	playback = player.get_stream_playback()


func _input(event:InputEvent):
	if event.is_action_pressed("build_a"):
		play("button_click")

func play(sound_name: String) -> void:
	if !player.playing: player.play()
	playback.play_stream(sfx[sound_name])
