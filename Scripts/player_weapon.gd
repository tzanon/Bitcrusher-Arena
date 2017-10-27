extends Sprite
# class for a player-held weapon

export(PackedScene) var projectile_scene

var proj_spawner

#export(float, 0.1, 10, 0.1) var fire_rate
var next_fire

func _ready():
	next_fire = 0
	proj_spawner = get_node("Projectile Spawner")

func fire():
	# spawn projectile
	var projectile = projectile_scene.instance()
	projectile.set_global_pos(proj_spawner.get_global_pos())
	projectile.set_global_rot(proj_spawner.get_global_rot())
	get_tree().get_root().add_child(projectile)
	#fire rate...
