extends Sprite
# class for a player-held weapon

export var debug_mode = false

# weapon name and player using it
export var weapon_name = "" setget ,get_weapon_name
var _user setget set_user # these used for score tracking?
var _user_ref


export(Vector2) var _hold_position
export(float) var _hold_rotation

# audio
export var using_audio_manager = true
export var _fire_sound_tag = ""

# projectiles
export(PackedScene) var Projectile
# in case we want to _fire from the barrel
onready var ProjSpawnPoint = get_node("ProjectileSpawnPoint")
var DEFAULT_PROJ_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.projectile

# nodes
var FireTimer
var AccuracyResetTimer
var AudioPlayer

# how often a weapon fires
export(float, 0.05, 2, 0.05) var _fire_rate
export(float, 0.05, 3, 0.05) var _accuracy_reset_time = 1
export(float) var _fire_arc_incr = 5.0
export var max_arc_angle = 30.0
var arc_angle = 0.0

# knockback
export(int, 200, 10000, 100) var knockbox_strength = 600

func _ready():
	set_process(true)
	
	# fire rate timer
	FireTimer = Timer.new()
	if !FireTimer:
		printerr("could not create fire timer for node ", self.name)
	add_child(FireTimer)
	FireTimer.wait_time = _fire_rate
	FireTimer.one_shot = true
	
	# accuracy cooldown timer
	AccuracyResetTimer = Timer.new()
	if !AccuracyResetTimer:
		printerr("could not create accuracy reset timer for node ", self.name)
	add_child(AccuracyResetTimer)
	AccuracyResetTimer.wait_time = _accuracy_reset_time
	AccuracyResetTimer.one_shot = true
	if AccuracyResetTimer.connect("timeout", self, "_reset_fire_arc") != 0:
		printerr("could not connect cooldown timeout to _reset_fire_arc")
	
	# set up audio player
	AudioPlayer = AudioStreamPlayer2D.new()
	if !AudioPlayer:
		printerr("could not create audio player for node ", self.name)
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

# reset fire angle arc so weapon is perfectly accurate
func _reset_fire_arc():
	arc_angle = 0.0

# increases range of firing angles up to its limit
func _increase_firing_arc():
	arc_angle = clamp(arc_angle + _fire_arc_incr, 0.0, max_arc_angle)

# returns random angle in range (-_arc_angle, _arc_angle)
func _get_rot_offset_in_arc():
	var offset = rand_range(-arc_angle, arc_angle)
	return offset

func _fire(spawn_pos):
	if FireTimer.time_left > 0:
		return
	
	self._play_fire_sound()
	
	var projectile = Projectile.instance()
	projectile.global_position = spawn_pos
	projectile.rotation_degrees = _user.global_rotation_degrees
	
	# perfect accuracy if cooldown done, increasingly inaccurate if not
	if AccuracyResetTimer.time_left <= 0:
		projectile.rotation_degrees += 0.0
	#else:
	#	projectile.rotation_degrees += self._get_rot_offset_in_arc()
	
	if AccuracyResetTimer.time_left > 0:
		projectile.rotation_degrees += self._get_rot_offset_in_arc()
	
	AccuracyResetTimer.start()
	
	if has_node(DEFAULT_PROJ_SPAWN_PATH):
		get_node(DEFAULT_PROJ_SPAWN_PATH).add_child(projectile)
	else:
		get_tree().get_root().add_child(projectile)
	self._increase_firing_arc()
	
	#var rot = _user.global_rotation
	#var knockback_direction = Vector2(-sin(rot), cos(rot)).normalized()
	#var knockback_force = knockbox_strength * knockback_direction
	#_user.apply_impulse(Vector2(0,0), knockback_force)
	
	FireTimer.start()
