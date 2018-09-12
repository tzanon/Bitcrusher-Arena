extends KinematicBody2D

export var debug_mode = false
export var _lifetime = 0.35

func _ready():
	var LifeTimer = get_node("Timer")
	LifeTimer.wait_time = _lifetime
	LifeTimer.connect("timeout", self, "_despawn")
	LifeTimer.start()

func collide_action():
	if debug_mode:
		print("barrier hit")
	_despawn()

func _despawn():
	if debug_mode:
		print("barrier despawned")
	self.queue_free()
