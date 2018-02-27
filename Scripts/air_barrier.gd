extends KinematicBody2D

export var debug_mode = false
export var lifetime = 0.35

func _ready():
	#set_fixed_process(true)
	
	var timer = get_node("Timer")
	timer.set_wait_time(lifetime)
	timer.connect("timeout", self, "_despawn")
	timer.start()

func _fixed_process(delta):
	if is_colliding():
		if debug_mode: print("barrier hit")
		_despawn()

func collide_action():
	if debug_mode: print("barrier hit")
	_despawn()

func _despawn():
	if debug_mode: print("barrier despawned")
	self.queue_free()
