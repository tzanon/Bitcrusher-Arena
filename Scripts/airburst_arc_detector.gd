extends Area2D

export var debug_mode = false

export var push_strength = 0.0
var _push_direction
var _affected_bodies = {}

var lifetime
var timer

func _ready():
	#self.connect("body_enter", self, "_detect_entry")
	
	var rot = get_global_rot()
	_push_direction = -Vector2(sin(rot), cos(rot)).normalized()
	
	lifetime = get_node("../AnimationPlayer").get_animation("AirburstArc").get_length()
	timer = get_node("../Timer")
	timer.set_wait_time(lifetime)
	timer.start()
	
	set_fixed_process(true)

func _fixed_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		_push_object(body)
	

func _detect_entry(body):
	_push_object(body)

func _push_object(body):
	if !body: return
	
	var time_left = timer.get_time_left()
	var life_factor = time_left / lifetime
	
	var body_id = body.get_instance_ID()
	if _affected_bodies.has(body_id): return
	
	if debug_mode: print("detector hit ", body.get_name())
	
	if body.get_type() == "RigidBody2D":
		if debug_mode: print("airburst pushing ", body)
		
		var push_force = life_factor * push_strength * _push_direction
		body.apply_impulse(Vector2(0,0), push_force)
	
	_affected_bodies[body_id] = ""
	

