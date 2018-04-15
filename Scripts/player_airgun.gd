extends "res://Scripts/player_weapon.gd"

export var debug_fire_mode = false

export(PackedScene) var air_flash_scene
export(PackedScene) var air_barrier_scene
export(PackedScene) var marker_scene

var ready_light

func _ready():
	._ready()
	
	ready_light = get_node("ReadyLight")
	fire_timer.connect("timeout", self, "_toggle_ready_light")
	self._toggle_ready_light()


func fire(spawn_pos):
	if fire_timer.get_time_left() <= 0:
		.fire(spawn_pos)
		
		# spawn deflection barrier
		var barrier = air_barrier_scene.instance()
		add_child(barrier)
		barrier.global_position = spawn_pos
		barrier.global_rotation = user.global_rotation
		
		# spawn muzzle flash effect
		var muzzle_flash = air_flash_scene.instance()
		add_child(muzzle_flash)
		muzzle_flash.global_position = proj_spawn_point.global_position
		muzzle_flash.global_rotation = global_rotation
		
		# spawn marker
		if debug_fire_mode:
			var marker = marker_scene.instance()
			get_node("//root/Level").add_child(marker)
			marker.position = spawn_pos
		
		_toggle_reload_light()
		
	

func _toggle_ready_light():
	ready_light.set_modulate(Color("22d218"))

func _toggle_reload_light():
	ready_light.set_modulate(Color("b81900"))

