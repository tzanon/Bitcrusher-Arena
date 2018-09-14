extends "res://Scripts/player_weapon.gd"

export var debug_fire_mode = false

export(PackedScene) var AirFlash
export(PackedScene) var AirBarrier
export(PackedScene) var Marker

var ReadyLight

func _ready():
	._ready()
	
	ReadyLight = get_node("ReadyLight")
	FireTimer.connect("timeout", self, "_toggle_ready_light")
	self._toggle_ready_light()


func _fire(spawn_pos):
	if FireTimer.get_time_left() <= 0:
		._fire(spawn_pos) # ???
		
		# spawn deflection barrier
		var barrier = AirBarrier.instance()
		add_child(barrier)
		barrier.global_position = spawn_pos
		barrier.global_rotation = _user.global_rotation
		
		# spawn muzzle flash effect
		var muzzle_flash = AirFlash.instance()
		add_child(muzzle_flash)
		muzzle_flash.global_position = ProjSpawnPoint.global_position
		muzzle_flash.global_rotation = global_rotation
		
		# spawn marker
		if debug_fire_mode:
			var marker = Marker.instance()
			get_node("//root/Level").add_child(marker)
			marker.position = spawn_pos
		
		_toggle_reload_light()
		
	

func _toggle_ready_light():
	ReadyLight.set_modulate(Color("22d218"))

func _toggle_reload_light():
	ReadyLight.set_modulate(Color("b81900"))

