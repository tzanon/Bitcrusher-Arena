extends Sprite
# class for a player-held weapon

var user setget set_user

export(PackedScene) var projectile_scene

onready var proj_spawn_point = get_node("ProjectileSpawnPoint")
var proj_spawn_path = "/root/Level/Projectiles"

var fire_timer

# how often a weapon fires
export(float, 0.05, 2, 0.05) var fire_rate

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
		projectile.set_global_rot(get_global_rot())
		get_node(proj_spawn_path).add_child(projectile)
		
		fire_timer.start()
