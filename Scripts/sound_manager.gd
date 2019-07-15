extends Node

var debug_mode = false
var muted = false

### sound tags ###
# player
const PLAYER_HIT = "player_hit" # TODO
const PLAYER_EXPL = "player_die"
# weapons
const LASER_FIRE = "laser_fire"
const SPUD_FIRE = "potato_fire"
const AIR_FIRE = "airgun_fire"
const BOMB_FIRE = "bombshot_fire"
const LASER_HIT = "laser_hit" # TODO if necessary
const SPUD_EXPL = "potato_explode"
const BOMB_EXPL = "bomb_explode"
# traps/hazards
const FIRE_JET = "fire_jet"
# menu/UI
const MENU_CONFIRM = ""
const MENU_BACK = ""
const START_GAME = ""


const SOUND_MAP = {
	# TODO: put dummy placeholder/debug sound for "" for testing
	LASER_FIRE : { sound=preload("res://Sounds/Weapons/laser_fire1.wav"), max_num=3 },
	SPUD_FIRE : { sound=preload("res://Sounds/Weapons/potato_fire1.wav"), max_num=3 },
	AIR_FIRE : { sound=preload("res://Sounds/Weapons/airgun_fire1.wav"), max_num=3 },
	BOMB_FIRE : { sound=preload("res://Sounds/Weapons/bombshot_fire1.wav"), max_num=3 },
	SPUD_EXPL : { sound=preload("res://Sounds/Weapons/potato_expl2.wav"), max_num=3 },
	BOMB_EXPL : { sound=preload("res://Sounds/Weapons/bomb_expl2.wav"), max_num=1 } , # need better one
	PLAYER_EXPL : { sound=preload("res://Sounds/Player/player_expl1.wav"), max_num=3 },
	FIRE_JET : { sound=preload("res://Sounds/Hazards/fire_jet1.wav"), max_num=3 },
	# TODO: sounds for menu button presses
	#"" : preload(""),
}

# each tag points to a list of audio players
var audio_player_arrays = {}

var AudioPlayer

# min number of sounds to play:
# 1 AP for each player (death, maybe pickup sound later)
# 1 AP for each type of trap

func _ready():
	debug_mode = true
	set_process_input(true)
	
	AudioPlayer = AudioStreamPlayer.new()
	self.add_child(AudioPlayer)
	
	_init_audio_arrays()

func _input(event):
	if event.is_action_pressed("mute_sound_effects"):
		muted = not muted
		if debug_mode:
			if muted:
				print("sound effects muted")
			else:
				print("sound effects unmuted")

func _init_audio_arrays():
	for tag in SOUND_MAP.keys():
		audio_player_arrays[tag] = []
		var sound_info = SOUND_MAP[tag]
		
		for i in sound_info.max_num:
			var player = AudioStreamPlayer.new()
			player.name = tag + " player " + String(i+1)
			player.stream = sound_info.sound
			audio_player_arrays[tag].append(player)
			self.add_child(player)
	

func _clear_audio_arrays():
	# TODO: delete all audio players and clear the dictionary
	pass

func get_sound_by_tag(sound_tag):
	if !SOUND_MAP.has(sound_tag):
		printerr("Sound tag '", sound_tag, "' not recognized")
		return
	return SOUND_MAP[sound_tag].sound

func play_sound_by_tag(sound_tag):
	if muted or sound_tag == "None":
		return
	
	if !SOUND_MAP.has(sound_tag):
		printerr("Sound tag '", sound_tag, "' not recognized")
		return
	
	var audio_array = audio_player_arrays[sound_tag]
	for audio_player in audio_array:
		if !audio_player.playing:
			audio_player.play()
			if debug_mode:
				print("playing sound with tag '", sound_tag, "'")
			return
	
	if debug_mode:
		print("no available audio players, dropping tag '" + sound_tag + "'")
	

func play_sound(sound_tag):
	if muted:
		return
	
	var effect = SOUND_MAP[sound_tag].sound
	if effect:
		AudioPlayer.stream = effect
		AudioPlayer.play()

