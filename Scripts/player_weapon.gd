extends Sprite
# class for a player-held weapon

export var debug_mode = false

export var weapon_name = "" setget ,get_weapon_name
var _user setget set_user # these used for score tracking?
var _user_ref
export(Vector2) var _hold_position
export(float) var _hold_rotation

export var using_audio_manager = true
export var _fire_sound_tag = ""


export(PackedScene) var Projectile
# in case we want to _fire from the barrel
onready var ProjSpawnPoint = get_node("ProjectileSpawnPoint")
var DEFAULT_PROJ_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.projectile # originally "/root/Level/Projectiles"

var FireTimer
var AudioPlayer

# how often a weapon fires
export(float, 0.05, 2, 0.05) var _fire_rate
export(float) var _accuracy_reset_time

# accuracy and knockback
export(int, 0, 45) var _max_accuracy_loss = 5
export(int, 200, 10000, 100) var _knockbox_strength = 600

func _ready():
	FireTimer = Timer.new()
	if !FireTimer:
		print("could not create fire timer!")
	add_child(FireTimer)
	FireTimer.wait_time = _fire_rate
	FireTimer.one_shot = true
	
	# TODO: test this
	AudioPlayer = AudioStreamPlayer2D.new()
	self.add_child(AudioPlayer)
	AudioPlayer.stream = AudioManager.get_sound_by_tag(_fire_sound_tag)
	

func get_weapon_name():
	return weapon_name

func set_user(weap_user):
	_user = weap_user
	_user_ref = weakref(weap_user)

func get_hold_pos():
	return _hold_position

# figure out angle metric
func get_hold_rotd():
	return _hold_rotation

func _play_fire_sound():
	if using_audio_manager:
		AudioManager.play_sound_by_tag(_fire_sound_tag)
	else:
		AudioPlayer.play()

func _fire(spawn_pos):
	if FireTimer.time_left <= 0:
		
		self._play_fire_sound()
		
		var projectile = Projectile.instance()
		projectile.global_position = spawn_pos
		# TODO: refactor accuracy calculation
		projectile.rotation_degrees = _user.global_rotation_degrees + _max_accuracy_loss * pow(2*randf() - 1, 3)
		
		if has_node(DEFAULT_PROJ_SPAWN_PATH):
			get_node(DEFAULT_PROJ_SPAWN_PATH).add_child(projectile)
		else:
			get_tree().get_root().add_child(projectile)
		
		var rot = _user.global_rotation
		var knockback_direction = Vector2(-sin(rot), cos(rot)).normalized()
		var knockback_force = _knockbox_strength * knockback_direction
		_user.apply_impulse(Vector2(0,0), knockback_force)
		
		FireTimer.start()
	

