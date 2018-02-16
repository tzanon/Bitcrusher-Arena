extends "res://Scripts/player_weapon.gd"

var ready_light

func _ready():
	._ready()
	
	ready_light = get_node("ReadyLight")
	fire_timer.connect("timeout", self, "_toggle_ready_light")
	self._toggle_ready_light()

func fire(spawn_pos):
	print("airgun firing")
	if fire_timer.get_time_left() <= 0:
		var projectile = projectile_scene.instance()
		#projectile.set_global_pos(proj_spawn_point.get_global_pos())
		#projectile.set_global_rot(get_global_rot())
		
		#get_node(proj_spawn_path).add_child(projectile)
		get_node(user.get_path()).add_child(projectile) # keep it with the barrel
		
		projectile.set_global_pos(spawn_pos)
		projectile.set_global_rot(get_global_rot())
		
		_toggle_reload_light()
		fire_timer.start()
		
	

func _toggle_ready_light():
	ready_light.set_modulate(Color("22d218"))

func _toggle_reload_light():
	ready_light.set_modulate(Color("b81900"))

