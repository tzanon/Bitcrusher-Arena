extends Area2D

export var debug_mode = false

export var _is_damaging = true
export var _damage_amount = 10
export var _impact_force = 0.0
export var _max_force_range = 100

# audio-related
export var using_audio_manager = false
export var _sound_tag = ""

var Animator
var AudioPlayer

# only damage a given body once
var _damaged_bodies = []
var _pushed_bodies = []

func _ready():
	Animator = get_node("AnimationPlayer")
	Animator.connect("animation_finished", self, "_despawn")
	
	if self.connect("body_entered", self, "_detect_entry") != 0:
		printerr("could not connect body entered signal")
	
	# play sound effect
	if using_audio_manager:
		AudioManager.play_sound_by_tag(_sound_tag)
	else:
		if has_node("AudioStreamPlayer2D"):
			AudioPlayer = get_node("AudioStreamPlayer2D")
			AudioPlayer.stream = AudioManager.get_sound_by_tag(_sound_tag)
			AudioPlayer.play()
	
	if debug_mode:
		print("explosion spawned")


func _detect_entry(body):
	if !_is_damaging:
		return
	
	# TODO: completely refactor this farce into a simple "if in blast, do fixed damage"
	
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


func _despawn(name):
	if debug_mode:
		print("explosion despawned, has damaged ", _damaged_bodies)
	self.queue_free()
