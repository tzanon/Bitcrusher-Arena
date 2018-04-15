extends Area2D

export var debug_mode = false

export var is_damaging = true
export var damage_amount = 0

export var impact_force = 0.0
export var max_force_range = 100

var animator

# only damage a given body once
var damaged_bodies = {}
var pushed_bodies = {}

func _ready():
	animator = get_node("AnimationPlayer")
	animator.connect("animation_finished", self, "_done_explosion")
	
	self.connect("body_entered", self, "_detect_entry")
	
	if debug_mode: print("explosion spawned")
	

func _detect_entry(body):
	
	if !is_damaging: return
	
	if debug_mode: print("expl hit ", body)
	var body_name = body.get_name()
	var body_id = body.get_instance_id()
	
	if body.is_in_group("Damageable") && !damaged_bodies.has(body_id):
		if debug_mode: print("exploding ", body_name)
		body.damage(damage_amount)
		damaged_bodies[body_id] = ""
	
	if body.get_class() == "RigidBody2D" && !pushed_bodies.has(body_id) && impact_force != 0.0:
		if debug_mode: print("pushing ", body_name)
		
		var distance = body.global_position - self.global_position
		if distance.x == 0.0: distance.x = 0.01
		if distance.y == 0.0: distance.y = 0.01
		
		var direction = distance.normalized()
		var strength_factor = max_force_range / distance.length()
		
		var impulse = impact_force * strength_factor * direction
		body.apply_impulse(Vector2(0,0), impulse)
		pushed_bodies[body_id] = ""
	

func _done_explosion(name):
	_despawn()

func _despawn():
	if debug_mode: print("explosion despawned, has damaged ", damaged_bodies)
	self.queue_free()

