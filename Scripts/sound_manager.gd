extends Node

const _sound_map = {
	"laser_fire" : preload("res://Sounds/Weapons/laser_fire1.wav"),
	"potato_fire" : preload("res://Sounds/Weapons/potato_fire1.wav"),
	"airgun_fire" : preload("res://Sounds/Weapons/airgun_fire1.wav"),
	"bombshot_fire" : preload("res://Sounds/Weapons/bombshot_fire1.wav"),
	"potato_explode" : preload("res://Sounds/Weapons/potato_expl2.wav"),
	"bomb_explode" : preload("res://Sounds/Weapons/bomb_expl2.wav"), # need to make a better one
	"player_die" : preload("res://Sounds/Player/player_expl1.wav"),
	"fire_jet" : preload("res://Sounds/Hazards/fire_jet1.wav"),
	#"" : preload(""),
}

var AudioPlayer

func _ready():
	AudioPlayer = $AudioStreamPlayer
	
func play_sound_by_tag(sound_tag):
	print("playing sound with tag ", sound_tag)
	var effect = _sound_map[sound_tag]
	if effect:
		AudioPlayer.stream = effect
		AudioPlayer.play()
	
