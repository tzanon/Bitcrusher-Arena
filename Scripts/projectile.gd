extends RigidBody2D

export(float) var max_speed # in case we want to have speed affected by certain factors, but kept within a range
export(float) var min_speed

export(int) var damage_amount = 0
export(float) var speed setget ,get_speed

export(PackedScene) var impact_effect_scene

export var effect_spawn_path = "/root/Level/Effects"

func _ready():
	set_mode(MODE_CHARACTER)
	set_fixed_process(true)
	set_contact_monitor(true)
	set_max_contacts_reported(1)
	
	var rot = get_global_rot()
	set_linear_velocity(self.get_linear_velocity() + Vector2(sin(rot), cos(rot)) * -speed)
	

func _fixed_process(delta):
	var bodies = get_colliding_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group("Damageable"):
			#print("hit something damageable")
			bodies[0].damage(damage_amount)
		self._explode()
	

func change_direction(angle):
	
	pass

func change_velocity(new_vel):
	
	pass

func bounce():
	
	pass

func get_speed():
	return speed

func _explode():
	if impact_effect_scene != null:
		# spawn explosion and delete
		var effect = impact_effect_scene.instance()
		effect.set_pos(self.get_global_pos())
		
		#get_tree().get_root().add_child(effect)
		#get_tree().get_root().get_node("Level/Effects").add_child(effect)
		get_node(effect_spawn_path).add_child(effect)
	
	self.queue_free()

