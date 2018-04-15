extends KinematicBody2D

export var debug_mode = false

export var damage_amount = 0
export var speed = 0.0 setget ,get_speed

# Bounce groups: Airbust, Reflective
export var bounce_groups = PoolStringArray()

# Speed multiplier for how faster/slower this projectile gets after bouncing
export(float, 0.1, 5, 0.1) var bounce_factor = 1.0 # maybe this should be in the class that bounces the projectile?

export(PackedScene) var impact_effect_scene
export var effect_spawn_path = "/root/Level/Effects"

export(String) var impact_sound_name

var _movement

var sample_player

func _ready():
	set_physics_process(true)
	
	var rot = global_rotation
	_movement = Vector2(-sin(rot), cos(rot)) * -speed
	
	#_movement = Vector2(sin(rot), cos(rot)) * -speed
	
	sample_player = get_node("SoundPlayer")

func _physics_process(delta):
	
	var collision = move_and_collide(_movement * delta)
	
	if collision:
		_handle_collision(collision.collider)
	

func add_velocity(vel):
	_movement += vel

func _handle_collision(body):
	if !body: return
	
	if debug_mode: print("hit something")
	if body.is_in_group("Damageable"):
		body.damage(damage_amount)
	
	var bounced = false
	
	for group in bounce_groups:
		if body.is_in_group(group):
			
			if debug_mode: print("bounced off a(n) ", group)
			self.bounce()
			bounced = true
			
			if group == "Airburst":
				body.collide_action()
			
			break
	
	if !bounced: # if not bouncing, exploding
		self._explode()

func bounce():
	var normal = get_collision_normal()
	_movement = normal.reflect(_movement) * bounce_factor
	
	var angle = atan(_movement.x / _movement.y)
	global_rotation = angle

func get_speed():
	return speed

func _explode():
	if impact_effect_scene != null:
		# spawn effect and delete
		var effect = impact_effect_scene.instance()
		effect.position = self.global_position
		
		if has_node(effect_spawn_path):
			get_node(effect_spawn_path).add_child(effect)
		else:
			get_tree().get_root().add_child(effect)
	
	
	if sample_player != null && impact_sound_name != null:
		if debug_mode: print("playing impact sound ", impact_sound_name)
		#var voice_id = sample_player.play(impact_sound_name, true)
		#sample_player.play(impact_sound_name)
		#sample_player.play_sound()
		
	
	self.queue_free()

