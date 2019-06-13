extends Area2D

export var debug_mode = false

export var _is_damaging = true
export var _damage_amount = 10

export var _impact_force = 0.0
export var _max_force_range = 100

export var sound_tag = ""

var Animator
var AudioPlayer

# only damage a given body once
var _damaged_bodies = []
var _pushed_bodies = []

func _ready():
	Animator = get_node("AnimationPlayer")
	Animator.connect("animation_finished", self, "_done_explosion")
	
	self.connect("body_entered", self, "_detect_entry")
	
	# TODO: replace with call to sound manager
	if has_node("AudioStreamPlayer2D"):
		AudioPlayer = get_node("AudioStreamPlayer2D")
	#if !AudioPlayer:
	#	AudioPlayer = AudioStreamPlayer2D.new()
	#	self.add_child(AudioPlayer)
	
	if AudioPlayer and AudioPlayer.stream:
		AudioPlayer.play()
	
	if debug_mode:
		print("explosion spawned")
	

func _detect_entry(body):
	if !_is_damaging:
		return
	
	if debug_mode:
		print("expl hit ", body)
	var body_name = body.get_name()
	var body_id = body.get_instance_id()
	
	if body.is_in_group("Damageable") && !_damaged_bodies.has(body_id):
		if debug_mode:
			print("exploding ", body_name)
		body.damage(_damage_amount)
		_damaged_bodies.append(body_id)
	
	if body.get_class() == "RigidBody2D" && !_pushed_bodies.has(body_id) && _impact_force != 0.0:
		if debug_mode:
			print("pushing ", body_name)
		
		var distance = body.global_position - self.global_position
		if distance.x == 0.0:
			distance.x = 0.01
		if distance.y == 0.0:
			distance.y = 0.01
		
		var direction = distance.normalized()
		var strength_factor = _max_force_range / distance.length()
		
		var impulse = _impact_force * strength_factor * direction
		body.apply_impulse(Vector2(0,0), impulse)
		_pushed_bodies.append(body_id)
	

func _done_explosion(name):
	_despawn()

func _despawn():
	if debug_mode:
		print("explosion despawned, has damaged ", _damaged_bodies)
	self.queue_free()

