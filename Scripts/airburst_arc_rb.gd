extends RigidBody2D

export var debug_mode = false

export var speed = 800
export var initial_mass = 100
export var max_push_strength = 0.0

var lifetime

var animator
var timer

var time_passed
var time_left

func _ready():
	set_mass(initial_mass)
	
	animator = get_node("AnimationPlayer")
	animator.connect("finished", self, "_despawn")
	lifetime = animator.get_animation("AirburstArc").get_length()
	
	timer = get_node("Timer")
	timer.set_wait_time(lifetime)
	timer.start()
	time_left = timer.get_time_left()
	time_passed = lifetime - time_left
	
	self.connect("body_enter", self, "_handle_collision")
	
	var rot = get_global_rot()
	var vel = Vector2(sin(rot), cos(rot)) * -speed
	self.set_linear_velocity(vel)
	
	set_fixed_process(true)
	

func _fixed_process(delta):
	time_left = timer.get_time_left()
	time_passed = lifetime - time_left
	
	#var mass_change = (timer.get_time_left() + lifetime / 3.0) / lifetime
	#var new_mass = mass_change * get_mass()
	#var new_mass = pow(timer.get_time_left(), 2) / lifetime * pow(initial_mass, 2)
	#var new_mass = ceil(pow(timer.get_time_left(), 2) / lifetime * initial_mass)
	#var new_mass = time_left / lifetime * initial_mass
	var new_mass = time_left / lifetime * get_mass() * (1 + time_passed / lifetime) # logarithmic decrease
	
	set_mass(new_mass)
	

func _handle_collision(body):
	if debug_mode: print("current mass is ", get_mass())
	
	if body.get_type() == "RigidBody2D":
		var rot = get_global_rot()
		var direction = Vector2(sin(rot), cos(rot)).normalized()
		
		var time_factor = (lifetime - time_passed) / lifetime
		var push_strength = time_factor * max_push_strength
		
		var push_vec = direction * push_strength
		
		body.apply_impulse(Vector2(0,0), push_vec)
		
		if debug_mode: print("force strength is ", push_vec.length())
		
		if body.is_in_group("ImpactVulnerable"):
			body.enable_impact_vulnerability()
		
	elif body.get_type() == "StaticBody2D" || body.is_in_group("Kinematic"):
		self._despawn()
	

func _despawn():
	if debug_mode: print("airburst arc despawned")
	self.queue_free()
