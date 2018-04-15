extends Sprite

export(PackedScene) var projectile_scene

onready var proj_spawn_point = get_node("ProjectileSpawnPoint")
const proj_spawn_path = "/root/Level/Projectiles"

var fire_timer

# how often a weapon fires
export(float, 0.05, 10, 0.05) var fire_rate = 3

func _ready():
	fire_timer = Timer.new()
	add_child(fire_timer)
	fire_timer.set_wait_time(fire_rate)
	fire_timer.connect("timeout", self, "fire")
	fire_timer.start()
	

func fire():
	var projectile = projectile_scene.instance()
	projectile.global_position = proj_spawn_point.global_position
	projectile.global_rotation = global_rotation
	
	var proj_node = get_node(proj_spawn_path)
	if proj_node:
		get_node(proj_spawn_path).add_child(projectile)
	else:
		get_tree().get_root().add_child(projectile)
	
