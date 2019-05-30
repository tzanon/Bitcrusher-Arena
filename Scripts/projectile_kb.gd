extends KinematicBody2D

export var debug_mode = false

enum bounceable_groups { NONE, REFLECTIVE, AIRBURST }

export var _damage_amount = 0
export var _speed = 0.0 setget ,get_speed

# Bounce groups: Airbust, Reflective (for potato, laser)
export var _bounce_groups = PoolStringArray()

# Speed multiplier for how faster/slower this projectile gets after bouncing
# maybe this should be in the class that bounces the projectile?
export(float, 0.1, 5, 0.1) var _bounce_factor = 1.0

export(PackedScene) var ImpactEffect
var DEFAULT_EFFECT_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.effect #"/root/Level/Effects"

# TBD
export(String) var _impact_sound_name

var _movement

# look up new sound playing
#var sample_player

func _ready():
	set_physics_process(true)
	
	var rot = global_rotation
	_movement = Vector2(-sin(rot), cos(rot)) * -_speed
	

func _physics_process(delta):
	
	var collision = move_and_collide(_movement * delta)
	
	if collision:
		_handle_collision(collision.collider)
	

func add_velocity(vel):
	_movement += vel

func _handle_collision(body):
	if !body:
		return
	
	if debug_mode:
		print("hit something")
	if body.is_in_group("Damageable"):
		body.damage(_damage_amount)
	
	var bounced = false
	
	for group in _bounce_groups:
		if body.is_in_group(group):
			
			if debug_mode:
				print("bounced off a(n) ", group)
			self.bounce()
			bounced = true
			
			if group == "Airburst":
				body.collide_action()
			
			break
	
	if !bounced: # if not bouncing, exploding
		self._explode()

func bounce():
	var normal = get_collision_normal()
	_movement = normal.reflect(_movement) * _bounce_factor
	
	var angle = atan(_movement.x / _movement.y)
	global_rotation = angle

func get_speed():
	return _speed

func _explode():
	if ImpactEffect != null:
		# spawn effect and delete
		var effect = ImpactEffect.instance()
		effect.position = self.global_position
		
		if has_node(DEFAULT_EFFECT_SPAWN_PATH):
			get_node(DEFAULT_EFFECT_SPAWN_PATH).add_child(effect)
		else:
			get_tree().get_root().add_child(effect)
	
	# do sound later
	#if sample_player != null && impact_sound_name != null:
		#if debug_mode: print("playing impact sound ", impact_sound_name)
		#var voice_id = sample_player.play(impact_sound_name, true)
		#sample_player.play(impact_sound_name)
		#sample_player.play_sound()
		
	
	self.queue_free()

