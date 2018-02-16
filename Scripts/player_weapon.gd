extends Sprite
# class for a player-held weapon

var user setget set_user

export(PackedScene) var projectile_scene

onready var proj_spawn_point = get_node("ProjectileSpawnPoint")
var proj_spawn_path = "/root/Level/Projectiles"

var fire_timer

# how often a weapon fires
export(float, 0.05, 2, 0.05) var fire_rate

# how often a weapon fires
export(int, 1, 45) var max_accuracy_loss = 5
export(int, 200, 10000, 200) var knockbox_strength = 600

func _ready():
	fire_timer = Timer.new()
	add_child(fire_timer)
	fire_timer.set_wait_time(fire_rate)
	fire_timer.set_one_shot(true)
	
	#set_process(true)

func _process(delta):
	#print(fire_timer.get_time_left())
	pass

func set_user(weap_user):
	user = weap_user

func fire(spawn_pos):
	if fire_timer.get_time_left() <= 0:
		var projectile = projectile_scene.instance()
		projectile.set_global_pos(spawn_pos)
		projectile.set_global_rotd(get_global_rotd() + max_accuracy_loss * pow(2*randf() - 1, 3))
		get_node(proj_spawn_path).add_child(projectile)
		
		var rot = get_global_rot()
		var knockback_direction = Vector2(sin(rot), cos(rot)).normalized()
		var knockback_force = knockbox_strength * knockback_direction
		user.apply_impulse(Vector2(0,0), knockback_force)

		fire_timer.start()
