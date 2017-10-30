extends Sprite
# class for a player-held weapon

export(PackedScene) var projectile_scene

export var proj_spawn_pos = Vector2(0,0)

var fire_timer

# how often a weapon fires
export(float, 0.05, 2, 0.05) var fire_rate

func _ready():	
	fire_timer = Timer.new()
	add_child(fire_timer)
	fire_timer.set_wait_time(fire_rate)
	fire_timer.set_one_shot(true)
	
	set_process(true)

func _process(delta):
	#print(fire_timer.get_time_left())
	pass

func fire():
	if fire_timer.get_time_left() <= 0:
		print("firing")
		var projectile = projectile_scene.instance()
		projectile.set_global_pos(get_global_transform().xform(proj_spawn_pos))
		projectile.set_global_rot(get_global_rot())
		get_tree().get_root().add_child(projectile)
		
		fire_timer.start()
	
