extends KinematicBody2D

export var debug_mode = false

export var _damage_amount = 0
export var _speed = 0.0 setget ,get_speed

# Bounce groups: Airbust, Reflective (for potato, laser)
export var _bounce_groups = PoolStringArray()

# Speed multiplier for how faster/slower this projectile gets after bouncing
# maybe this should be in the class that bounces the projectile?
export(float, 0.1, 5, 0.1) var _bounce_factor = 1.0

export(PackedScene) var ImpactEffect
const DEFAULT_EFFECT_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.effect #"/root/Level/Effects"

# audio-related
export var _impact_sound_tag = ""

var _movement

# look up new sound playing
var AudioPlayer

func _ready():
	set_physics_process(true)
	
	var rot = global_rotation
	_movement = Vector2(-sin(rot), cos(rot)) * -_speed

func _physics_process(delta):
	var collision = move_and_collide(_movement * delta, false)
	
	if collision:
		_handle_collision(collision)

func add_velocity(vel):
	_movement += vel

func _handle_collision(collision):
	var body = collision.collider
	
	if body.is_in_group("Damageable"):
		if (debug_mode):
			print("damaging ", body.name)
		body.damage(_damage_amount)
	
	var bounced = false
	
	for group in _bounce_groups:
		if body.is_in_group(group):
			if debug_mode:
				print("bounced off: ", group)
			
			#self.bounce()
			_movement = _movement.bounce(collision.normal)
			global_rotation = atan(_movement.x / _movement.y)
			
			bounced = true
			
			if group == "Airburst":
				body.collide_action()
			break
	
	if !bounced: # if not bouncing, exploding
		self._explode()

func bounce():
	var normal = Vector2() #get_collision_normal()
	# TODO: update bouncing with 3.1 normals
	
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
	
	# play sound effect
	AudioManager.play_sound_by_tag(_impact_sound_tag)
	
	self.queue_free()

