extends KinematicBody2D

export var debug_mode = false

export var damage_amount = 0
export var speed = 0.0 setget ,get_speed

# Bounce groups: Airbust, Reflective
export var bounce_groups = StringArray()

# Speed multiplier for how faster/slower this projectile gets after bouncing
export(float, 0.1, 5, 0.1) var bounce_factor = 1.0 # maybe this should be in the class that bounces the projectile?

export(PackedScene) var impact_effect_scene
export var effect_spawn_path = "/root/Level/Effects"

export(String) var impact_sound_name

var _movement

var sample_player

func _ready():
	set_fixed_process(true)
	
	var rot = get_global_rot()
	_movement = Vector2(sin(rot), cos(rot)) * -speed
	
	sample_player = get_node("SoundPlayer")

func _fixed_process(delta):
	if is_colliding():
		_handle_collision(get_collider())
	move(_movement * delta)

func add_velocity(velocity):
	_movement += velocity

func _handle_collision(body):
	if !body: return
	
	if debug_mode: print("hit something")
	if body.is_in_group("Damageable"):
			body.damage(damage_amount)
	
	var bounced = false
	
	for group in bounce_groups:
		if body.is_in_group(group):
			var normal = get_collision_normal()
			_movement = normal.reflect(_movement) * bounce_factor
			
			var angle = atan(_movement.x / _movement.y)
			set_global_rot(angle)
			
			if debug_mode: print("bounced off a(n) ", group)
			bounced = true
			
			if group == "Airburst":
				get_collider().collide_action()
			
			break
	
	if !bounced: # if not bouncing, exploding
		self._explode()

func bounce():
	if debug_mode: print("bouncing")
	
	var normal = get_collision_normal()
	if debug_mode: print("normal is ", normal)
	#_movement = normal.reflect(_movement) * bounce_factor
	
	#var angle = atan(_movement.x / _movement.y)
	#set_global_rot(angle)

func get_speed():
	return speed

func _explode():
	if impact_effect_scene != null:
		# spawn explosion and delete
		var effect = impact_effect_scene.instance()
		effect.set_pos(self.get_global_pos())
		
		get_node(effect_spawn_path).add_child(effect)
	
	if sample_player != null && impact_sound_name != null:
		if debug_mode: print("playing impact sound ", impact_sound_name)
		#var voice_id = sample_player.play(impact_sound_name, true)
		sample_player.play(impact_sound_name)
		#sample_player.play_sound()
		
	
	self.queue_free()

