extends RigidBody2D

export var debug_mode = false

export(int) var _damage_amount = 0
export(float) var _timeout = 0.3

var HarmTimer

onready var _time = 0

func _ready():
	# TODO: get rid of this physics process once current method is tested
	#set_physics_process(true)
	
	self.connect("body_entered", self, "_handle_collision")
	
	HarmTimer = get_node("Timer")
	HarmTimer.wait_time = _timeout
	HarmTimer.one_shot = true
	

func _physics_process(delta):
	
	if _time <= 0:
		var bodies = get_colliding_bodies()
		if bodies.size() > 0:
			if bodies[0].is_in_group("Damageable"):
				bodies[0].damage(_damage_amount)
				_time = _timeout
	else:
		_time -= delta

	if debug_mode:
		print(_time)
	

func _handle_collision(body):
	if HarmTimer.time_left == 0 && body.is_in_group("Damageable"):
		body.damage(_damage_amount)
		HarmTimer.start()
	
