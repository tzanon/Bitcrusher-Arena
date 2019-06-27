extends Area2D

export var debug_mode = false

export var _is_damaging = true
export var _is_pushing = true

export var _damage_amount = 10
export var _impact_force = 0.0
export var _max_force_range = 100

# for new damage model
export(float) var _damage_interval = 200 # milliseconds!

# audio-related
export var using_audio_manager = false
export var _sound_tag = ""

var Animator
var AudioPlayer
var DamageTimer

# only damage a given body once
var _damaged_bodies = []
var _pushed_bodies = []

# new functionality: explosion acts as damaging area
# i.e. every x milliseconds it applies damage to anything
# in its radius
# only push away bodies when first spawned, no repeats

func _ready():
	Animator = get_node("AnimationPlayer")
	Animator.connect("animation_finished", self, "_despawn")
	
	if _is_damaging:
		# set up damage timer
		if has_node("DamageTimer"):
			DamageTimer = get_node("DamageTimer")
		else:
			DamageTimer = Timer.new()
			self.add_child(DamageTimer)
		DamageTimer.one_shot = true
		DamageTimer.wait_time = _damage_interval / 1000
		DamageTimer.connect("timeout", self, "_apply_damage")
		
		# deal initial damage and impulse force
		self._apply_damage()
	
	if _is_pushing:
		self._apply_push_force()
	
	#if self.connect("body_entered", self, "_detect_entry") != 0:
	#	printerr("could not connect body entered signal")
	
	# play sound effect
	if _sound_tag != "":
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
		body.apply_impulse(Vector2(0, 0), impulse)
		_pushed_bodies.append(body_id)

func _apply_push_force():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_class("RigidBody2D"):
			if debug_mode:
				print("explosion pushing ", body.name)
			var direction = (body.global_position - self.global_position).normalized()
			var impulse = _impact_force * direction
			body.apply_impulse(Vector2(0, 0), impulse)
		
		# for future redesign of player and player-related physics
		if body.is_in_group("KBCustomPhysics"):
			# TODO: apply custom "force" to non-rb player
			# TODO: make parent script for KBs with custom forces?
			pass

func _apply_damage():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Damageable"):
			if debug_mode:
				print("explosion damaging ", body.name)
			body.damage(_damage_amount)
	DamageTimer.start()

func _despawn(name):
	if debug_mode:
		print("explosion despawned, has damaged ", _damaged_bodies)
	self.queue_free()
