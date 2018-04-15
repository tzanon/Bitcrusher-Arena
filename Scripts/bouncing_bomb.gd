extends RigidBody2D

export var damage_amount = 10
export var speed = 300

export var has_random_lifetime = false
export(float, 0.5, 10.0, 0.5) var lifetime = 5.0
export(float, 0.5, 10.0, 0.5) var min_lifetime = 1.0
export(float, 0.5, 10.0, 0.5) var max_lifetime = 10.0

export var self_collision_time = 0.2

export(PackedScene) var explosion_effect_scene
export var effect_spawn_path = "/root/Level/Effects"

export(String) var explode_sound_name

var life_timer
var sample_player

func _ready():
	life_timer = get_node("Timer")
	
	if has_random_lifetime:
		var rand_lt = rand_range(min_lifetime, max_lifetime)
		life_timer.set_wait_time(rand_lt)
	else:
		life_timer.set_wait_time(lifetime)
	
	life_timer.start()
	life_timer.connect("timeout", self, "_explode")
	
	self.connect("body_entered", self, "_handle_collision")
	
	var rot = global_rotation
	var vel = Vector2(sin(rot), cos(rot)) * -speed
	self.set_linear_velocity(vel)
	
	set_collision_mask_bit(2, false)
	
	set_physics_process(true)

func _physics_process(delta):
	
	if life_timer.get_wait_time() - life_timer.get_time_left() > self_collision_time:
		set_collision_mask_bit(2, true)
		set_physics_process(false)
	

func _handle_collision(body):
	if !body: return
	
	if body.is_in_group("Damageable"):
		body.damage(damage_amount)
		self._despawn()
	

func _explode():
	
	if sample_player && explode_sound_name:
		sample_player.play(explode_sound_name)
	
	var explosion = explosion_effect_scene.instance()
	explosion.position = self.global_position
	
	if has_node(effect_spawn_path):
		get_node(effect_spawn_path).add_child(explosion)
	else:
		get_tree().get_root().add_child(explosion)
	
	self._despawn()


func _despawn():
	self.queue_free()
