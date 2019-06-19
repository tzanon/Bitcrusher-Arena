extends Node

# TODO: make this a singleton; other scenes need audio

var debug_mode = false
var muted = false

# order: UI, player, weapon firing, weapon hit/effect, traps
enum SoundTags {
	NONE,
	MENU_CONFIRM, MENU_BACK, START_GAME,
	PLAYER_HIT, PLAYER_EXPL,
	LASER_FIRE, SPUD_FIRE, AIR_FIRE, BOMB_FIRE,
	LASER_HIT, SPUD_EXPL, BOMB_EXPL,
	FIRE_JET
}

const SOUND_MAP = {
	# TODO: put dummy placeholder/debug sound for "" for testing
	"laser_fire" : preload("res://Sounds/Weapons/laser_fire1.wav"),
	"potato_fire" : preload("res://Sounds/Weapons/potato_fire1.wav"),
	"airgun_fire" : preload("res://Sounds/Weapons/airgun_fire1.wav"),
	"bombshot_fire" : preload("res://Sounds/Weapons/bombshot_fire1.wav"),
	"potato_explode" : preload("res://Sounds/Weapons/potato_expl2.wav"),
	"bomb_explode" : preload("res://Sounds/Weapons/bomb_expl2.wav"), # need to make a better one
	"player_die" : preload("res://Sounds/Player/player_expl1.wav"),
	"fire_jet" : preload("res://Sounds/Hazards/fire_jet1.wav"),
	# TODO: sounds for menu button presses
	#"" : preload(""),
}

var sound_info = {}

#export var max_audio_players = 32

var AudioPlayer

# min number of sounds to play:
# 1 AP for each player (death, maybe pickup sound later)
# 1 AP for each type of trap

func _ready():
	debug_mode = true
	
	AudioPlayer = AudioStreamPlayer.new()
	self.add_child(AudioPlayer)

func get_sound_by_tag(sound_tag):
	if !SOUND_MAP.has(sound_tag):
		printerr("Sound tag '", sound_tag, "' not recognized")
		return
	return SOUND_MAP[sound_tag]

func play_sound_by_tag(sound_tag):
	if muted:
		return
	
	if !SOUND_MAP.has(sound_tag):
		printerr("Sound tag '", sound_tag, "' not recognized")
		return
	
	if debug_mode:
		print("playing sound with tag '", sound_tag, "'")
	
	var effect = SOUND_MAP[sound_tag]
	if effect:
		AudioPlayer.stream = effect
		AudioPlayer.play()
	
