extends Sprite
# class for a player-held weapon

export var debug_mode = false

export var weapon_name = "" setget ,get_weapon_name

var user setget set_user
var user_ref
export(Vector2) var hold_position
export(float) var hold_rotation

export(PackedScene) var projectile_scene

export(String) var fire_sound_name

onready var proj_spawn_point = get_node("ProjectileSpawnPoint")
const proj_spawn_path = "/root/Level/Projectiles"

var fire_timer
var sample_player

# how often a weapon fires
export(float, 0.05, 2, 0.05) var fire_rate

# how often a weapon fires
export(int, 0, 45) var max_accuracy_loss = 5
export(int, 200, 10000, 100) var knockbox_strength = 600

func _ready():
	fire_timer = Timer.new()
	add_child(fire_timer)
	fire_timer.set_wait_time(fire_rate)
	fire_timer.set_one_shot(true)
	
	if has_node("SamplePlayer"):
		sample_player = get_node("SamplePlayer")
	

func get_weapon_name():
	return weapon_name

func set_user(weap_user):
	user = weap_user
	user_ref = weakref(weap_user)
	

func get_hold_pos():
	return hold_position

func get_hold_rot():
	
	pass

# figure out angle metric
func get_hold_rotd():
	return hold_rotation

func fire(spawn_pos):
	if fire_timer.get_time_left() <= 0:
		
		if sample_player && fire_sound_name:
			if debug_mode: print("playing fire sound ", fire_sound_name)
			# play sound
		
		var projectile = projectile_scene.instance()
		projectile.global_position = spawn_pos
		projectile.rotation_degrees = user.global_rotation_degrees + max_accuracy_loss * pow(2*randf() - 1, 3)
		
		#var proj_node = get_node(proj_spawn_path)
		if has_node(proj_spawn_path):
			get_node(proj_spawn_path).add_child(projectile)
		else:
			get_tree().get_root().add_child(projectile)
		
		var rot = user.global_rotation
		var knockback_direction = Vector2(sin(rot), cos(rot)).normalized()
		var knockback_force = knockbox_strength * knockback_direction
		user.apply_impulse(Vector2(0,0), knockback_force)
		
		fire_timer.start()

func _spawn_proj(spawn_pos):
	
	pass
