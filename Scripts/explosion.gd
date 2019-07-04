extends Area2D

export var debug_mode = false
export var raycast_debug = false
var dealing_dmg = false

export var _is_damaging = true
export var _is_pushing = true

export var _damage_amount = 10
export var _impact_force = 0.0
export var _max_force_range = 100
export var _raycast_range = 60

# for new damage model
export(float) var _damage_interval = 200 # milliseconds!

# audio-related
export var using_audio_manager = false
export var _sound_tag = ""

var Animator
var AudioPlayer
var DamageTimer
var ObstructionDetectCast

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
	
	ObstructionDetectCast = $RayCast2D
	
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
	else:
		_damage_amount = 0.0
	
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

func _draw():
	if raycast_debug:
		_draw_raycast()

func _draw_raycast():
	if !raycast_debug or !dealing_dmg:
		return
	
	var range_end = ObstructionDetectCast.cast_to
	draw_line(Vector2(), range_end, Color.green, 4.5) # draw full cast
	
	if ObstructionDetectCast.is_colliding():
		var hit_pos_global = ObstructionDetectCast.get_collision_point()
		var hit_pos_local = self.to_local(hit_pos_global)
		draw_line(Vector2(), hit_pos_local, Color.purple, 3.0) # draw line to object

func _apply_push_force():
	if !_is_pushing:
		return
	
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
			# TODO: apply custom "force" to non-rb objects
			# TODO: make parent script for KBs with custom forces?
			pass

func _apply_damage():
	dealing_dmg  = true
	
	var overlapping_bodies = get_overlapping_bodies()
	ObstructionDetectCast.enabled = true
	
	for body in overlapping_bodies:
		if body.is_in_group("Damageable") and !_is_target_obstructed(body):
			body.damage(_damage_amount)
	
	DamageTimer.start()

# determine if there is an object between the explosion and target
func _is_target_obstructed(target):
	var unscaled_direction = target.global_position-self.global_position
	var direction = unscaled_direction.normalized()
	var cast_vec = _raycast_range * direction
	
	ObstructionDetectCast.cast_to = cast_vec
	self.update() # update debug lines
	
	var coll = ObstructionDetectCast.get_collider()
	
	# if RC finds target or nothing (somehow), no obstruction
	if coll == null:
		if debug_mode:
			print("ERC: raycast detected nothing/NULL")
		return false
	elif coll == target:
		if debug_mode:
			print("ERC: nothing obstructing damageable object")
		return false
	
	# if it finds something else in front of the target, it is obstructed
	else:
		if debug_mode:
			print("ERC: target body is blocked, not doing damage")
		return true
	

func _despawn(name):
	self.queue_free()
