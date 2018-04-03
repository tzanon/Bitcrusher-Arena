extends RigidBody2D

export(int) var damage_amount = 0
export(float) var timeout = 0.3

onready var _time = 0

func _ready():
	set_mode(MODE_CHARACTER)
	set_fixed_process(true)
	set_contact_monitor(true)
	set_max_contacts_reported(1)
	

func _fixed_process(delta):
	if _time <= 0:
		var bodies = get_colliding_bodies()
		if bodies.size() > 0:
			if bodies[0].is_in_group("Damageable"):
				bodies[0].damage(damage_amount)
				_time = timeout
	else: _time -= delta

	print(_time)
	