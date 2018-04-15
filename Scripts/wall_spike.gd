extends RigidBody2D

export var debug_mode = false

export(int) var damage_amount = 0
export(float) var timeout = 0.3

var harm_timer

onready var _time = 0

func _ready():
	#set_physics_process(true)
	
	self.connect("body_entered", self, "_handle_collision")
	
	harm_timer = get_node("Timer")
	harm_timer.set_wait_time(timeout)
	harm_timer.set_one_shot(true)
	

func _physics_process(delta):
	
	if _time <= 0:
		var bodies = get_colliding_bodies()
		if bodies.size() > 0:
			if bodies[0].is_in_group("Damageable"):
				bodies[0].damage(damage_amount)
				_time = timeout
	else: _time -= delta

	if debug_mode: print(_time)
	

func _handle_collision(body):
	if harm_timer.get_time_left() == 0 && body.is_in_group("Damageable"):
		body.damage(damage_amount)
		harm_timer.start()
	
