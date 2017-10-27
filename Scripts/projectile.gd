extends RigidBody2D

export(int) var damage
export(float) var speed

func _ready():
	set_mode(MODE_CHARACTER)
	set_fixed_process(true)
	set_contact_monitor(true)
	set_max_contacts_reported(1)
	
	var rot = get_global_rot()
	set_linear_velocity(Vector2(sin(rot), cos(rot)) * -speed)
	

func _fixed_process(delta):
	var bodies = get_colliding_bodies()
	
	if bodies.size() > 0:
		print("hit something")
		if bodies[0].is_in_group("Destructable"):
			# damage object
			pass
		
		self.queue_free()
	


