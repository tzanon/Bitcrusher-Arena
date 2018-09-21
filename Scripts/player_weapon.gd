extends Sprite
# class for a player-held weapon

export var debug_mode = false

export var weapon_name = "" setget ,get_weapon_name

var _user setget set_user # these used for score tracking?
var _user_ref
export(Vector2) var _hold_position
export(float) var _hold_rotation

export(PackedScene) var Projectile
# in case we want to _fire from the barrel
onready var ProjSpawnPoint = get_node("ProjectileSpawnPoint")
var DEFAULT_PROJ_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.projectile # originally "/root/Level/Projectiles"

var FireTimer

# how often a weapon fires
export(float, 0.05, 2, 0.05) var _fire_rate

# how often a weapon fires
export(int, 0, 45) var _max_accuracy_loss = 5
export(int, 200, 10000, 100) var _knockbox_strength = 600

func _ready():
	FireTimer = Timer.new()
	if !FireTimer:
		print("could not create fire timer!")
	add_child(FireTimer)
	FireTimer.wait_time = _fire_rate
	FireTimer.one_shot = true

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

func _fire(spawn_pos):
	if FireTimer.time_left <= 0:
		
		# TODO: play _fire sound
		
		var projectile = Projectile.instance()
		projectile.global_position = spawn_pos
		projectile.rotation_degrees = _user.global_rotation_degrees + _max_accuracy_loss * pow(2*randf() - 1, 3)
		
		#var proj_node = get_node(DEFAULT_PROJ_SPAWN_PATH)
		if has_node(DEFAULT_PROJ_SPAWN_PATH):
			get_node(DEFAULT_PROJ_SPAWN_PATH).add_child(projectile)
		else:
			get_tree().get_root().add_child(projectile)
		
		var rot = _user.global_rotation
		var knockback_direction = Vector2(-sin(rot), cos(rot)).normalized()
		var knockback_force = _knockbox_strength * knockback_direction
		_user.apply_impulse(Vector2(0,0), knockback_force)
		
		FireTimer.start()
	

