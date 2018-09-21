extends RigidBody2D

export var _damage_amount = 10
export var _speed = 300

export var _has_random_lifetime = false
export(float, 0.5, 10.0, 0.5) var _lifetime = 5.0
export(float, 0.5, 10.0, 0.5) var _min_lifetime = 1.0
export(float, 0.5, 10.0, 0.5) var _max_lifetime = 10.0

export var _self_collision_time = 0.2 # period when bombs can't collide with each other

export(PackedScene) var ExplosionEffect

var LifeTimer

func _ready():
	LifeTimer = get_node("Timer")
	
	if _has_random_lifetime:
		var rand_lt = rand_range(_min_lifetime, _max_lifetime)
		LifeTimer.wait_time = rand_lt
	else:
		LifeTimer.wait_time = _lifetime
	
	LifeTimer.connect("timeout", self, "_explode")
	LifeTimer.start()
	
	self.connect("body_entered", self, "_handle_collision")
	
	var rot = self.global_rotation
	var vel = Vector2(sin(rot), cos(rot)) * -_speed
	self.linear_velocity = vel
	
	set_collision_mask_bit(2, false)
	
	set_physics_process(true)

func _physics_process(delta):
	if LifeTimer.wait_time - LifeTimer.time_left > _self_collision_time:
		set_collision_mask_bit(2, true)
		set_physics_process(false)
	

func _handle_collision(body):
	if !body:
		return
	
	if body.is_in_group("Damageable"):
		body.damage(_damage_amount)
		self._despawn()
	

func _explode():
	
	# play sound (centralize somehow?)
	
	var explosion = ExplosionEffect.instance()
	explosion.position = self.global_position
	
	if has_node(GameInfo.NODE_SPAWN_PATHS.effect):
		get_node(GameInfo.NODE_SPAWN_PATHS.effect).add_child(explosion)
	else:
		get_tree().get_root().add_child(explosion)
	
	self._despawn()


func _despawn():
	self.queue_free()
