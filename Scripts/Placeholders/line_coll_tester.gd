extends KinematicBody2D

var affected_bodies = {}

func _ready():
	#connect("body_enter", self, "_detect_hit")
	
	#set_fixed_process(true)
	pass

func _fixed_process(delta):
	
	pass

func _detect_hit(body):
	if body.is_in_group("SolidProjectile") || body.is_in_group("LightProjectile"): #&& !affected_bodies.has(body.get_instance_ID()):
		print("deflecting ", body.get_name())
		
		var current_velocity = body.get_linear_velocity()
		
		var new_velocity = Vector2(current_velocity.x, -current_velocity.y)
		
		var new_direction = new_velocity / body.speed
		var new_angle = atan(new_direction.x / new_direction.y)
		
		print("old angle was ", body.get_global_rot())
		print("new angle is ", new_angle)
		
		body.set_linear_velocity(new_velocity)
		body.set_global_rot(new_angle)
		
		#affected_bodies[body.get_instance_ID()] = ""
	
	if body.is_in_group("SolidProjectileKB"):
		# TODO: collision handling for KB projectiles
		# -would be best to handle in projectile class bc of KB
		var normal = body.get_collision_normal()
		
		
		pass
	
	

