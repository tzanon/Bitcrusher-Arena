extends RigidBody2D

export var debug_mode = false

export var _speed = 800
export var _initial_mass = 100
export var _max_push_strength = 0.0

var _lifetime

var Animator
var LifeTimer

var _time_passed
var _time_left

func _ready():
	set_mass(_initial_mass)
	
	Animator = get_node("AnimationPlayer")
	Animator.connect("animation_finished", self, "_airburst_finish")
	_lifetime = Animator.get_animation("AirburstArc").get_length()
	
	LifeTimer = get_node("Timer")
	LifeTimer.set_wait_time(_lifetime)
	LifeTimer.start()
	_time_left = LifeTimer.get_time_left()
	_time_passed = _lifetime - _time_left
	
	self.connect("body_entered", self, "_handle_collision")
	
	var rot = global_rotation
	var vel = Vector2(-sin(rot), cos(rot)) * -_speed
	self.set_linear_velocity(vel)
	
	set_physics_process(true)
	

func _physics_process(delta):
	_time_left = LifeTimer.get_time_left()
	_time_passed = _lifetime - _time_left
	
	# logarithmic decrease
	var new_mass = _time_left / _lifetime * get_mass() * (1 + _time_passed / _lifetime)
	
	set_mass(new_mass)
	

func _handle_collision(body):
	if debug_mode:
		print("current mass is ", get_mass())
	
	if body.get_class() == "RigidBody2D":
		var rot = global_rotation
		var direction = Vector2(sin(rot), cos(rot)).normalized()
		
		var time_factor = (_lifetime - _time_passed) / _lifetime
		var push_strength = time_factor * _max_push_strength
		
		var push_vec = direction * push_strength
		
		body.apply_impulse(Vector2(0,0), push_vec)
		
		if debug_mode:
			print("force strength is ", push_vec.length())
		
		if body.is_in_group("ImpactVulnerable"):
			body.enable_impact_vulnerability()
		
	elif body.get_class() == "StaticBody2D" || body.is_in_group("Kinematic"):
		self._despawn()
	

func _airburst_finish(name):
	self._despawn()

func _despawn():
	if debug_mode:
		print("airburst arc despawned")
	self.queue_free()
