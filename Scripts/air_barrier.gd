extends KinematicBody2D

export var debug_mode = false
export var lifetime = 0.35

func _ready():
	var timer = get_node("Timer")
	timer.set_wait_time(lifetime)
	timer.connect("timeout", self, "_despawn")
	timer.start()

func collide_action():
	if debug_mode: print("barrier hit")
	_despawn()

func _despawn():
	if debug_mode: print("barrier despawned")
	self.queue_free()
