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

var life_timer

func _ready():
	life_timer = get_node("Timer")
	
	if has_random_lifetime:
		var rand_lt = rand_range(min_lifetime, max_lifetime)
		life_timer.set_wait_time(rand_lt)
	else:
		life_timer.set_wait_time(lifetime)
	
	life_timer.start()
	life_timer.connect("timeout", self, "_explode")
	
	self.connect("body_enter", self, "_handle_collision")
	
	var rot = get_global_rot()
	var vel = Vector2(sin(rot), cos(rot)) * -speed
	self.set_linear_velocity(vel)
	
	set_collision_mask_bit(2, false)
	
	set_fixed_process(true)

func _fixed_process(delta):
	
	if life_timer.get_wait_time() - life_timer.get_time_left() > self_collision_time:
		set_collision_mask_bit(2, true)
		set_fixed_process(false)
	

func _handle_collision(body):
	if !body: return
	
	if body.is_in_group("Damageable"):
		body.damage(damage_amount)
		self._despawn()
	

func _explode():
	# spawn explosion
	var explosion = explosion_effect_scene.instance()
	explosion.set_pos(self.get_global_pos())
	get_node(effect_spawn_path).add_child(explosion)
	self._despawn()


func _despawn():
	self.queue_free()
