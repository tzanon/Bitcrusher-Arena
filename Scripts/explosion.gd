extends Area2D

export var debug_mode = false

export var _is_damaging = true
export var _is_pushing = true
export var _damage_per_second = 10
export var _impact_force = 0.0

export var _sound_tag = ""

var Animator

func _ready():
	Animator = get_node("AnimationPlayer")
	Animator.connect("animation_finished", self, "_despawn")
	
	if _is_damaging:
		set_process(true)
	else:
		_damage_per_second = 0
	
	if _is_pushing:
		self._apply_push_force()
	
	# play sound effect
	if _sound_tag != "":
		AudioManager.play_sound_by_tag(_sound_tag)
	
	if debug_mode:
		print("explosion spawned")

func _process(delta):
	if !_is_damaging:
		return
	
	_apply_damage_over_time(delta)
	

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
			# TODO: make parent script for KBs with custom forces
			pass

func _apply_damage_over_time(time_step):
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Damageable"):
			body.damage(_damage_per_second * time_step)

func _despawn(name):
	self.queue_free()
