extends Sprite

export(PackedScene) var projectile_scene

onready var proj_spawn_point = get_node("ProjectileSpawnPoint")

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
	projectile.set_global_pos(proj_spawn_point.get_global_pos())
	projectile.set_global_rot(get_global_rot())
	get_tree().get_root().add_child(projectile)
