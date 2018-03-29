extends RigidBody2D

export var debug_mode = false
export var keyboard_mode = false

# gamepad device used to control this player
var gamepad_id = -1 setget set_gamepad_id
var name = "default" #setget set_name

export var manager_path = "/root/Level/Layout/PlayerManager"

var health = 100
signal health_changed(player_name, player_health)
signal died(player_name)

const joystick_idle_limit = 0.3

export var acceleration = 40
export var top_speed = 300
var rotd_speed = 270

export var base_collide_damage = 5

export var speed_pain_threshold = 300 # keep this for damage from other objects!
export var base_impact_damage = 5

export var impact_vulnerability_period = 0.3

var impact_vulnerable

var impact_vulnerable_filter

const start_weapon = preload("res://Scenes/Weapons/PlayerLaser.tscn")
var weapon_pos
var weapon

var animator
var item_detector
var impact_vulnerability_timer
var body_sprite

var directional_force = Vector2()
const DIRECTION = {
	ZERO = Vector2(0,0),
	LEFT = Vector2(-1,0),
	RIGHT = Vector2(1,0),
	UP = Vector2(0,-1),
	DOWN = Vector2(0,1)
}

const proj_spawn_positions = {
	"Laser" : Vector2(0, -44),
	"Potato Launcher" : Vector2(0, -40),
	"Airburst Gun" : Vector2(0, -24),
	"Bombshot" : Vector2(0, -40)
}

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	self.connect("body_enter", self, "_detect_collision")
	
	animator = get_node("AnimationPlayer")
	weapon_pos = get_node("WeaponPosition").get_pos()
	impact_vulnerable_filter = get_node("VulnerableFilter")
	
	body_sprite = get_node("BodySprite")
	
	impact_vulnerability_timer = get_node("VulnerableTimer")
	impact_vulnerability_timer.set_one_shot(true)
	impact_vulnerability_timer.set_wait_time(impact_vulnerability_period)
	impact_vulnerability_timer.connect("timeout", self, "disable_impact_vulnerability")
	
	impact_vulnerable = false
	impact_vulnerable_filter.hide()
	
	item_detector = get_node("PickupDetector")
	_equip_weapon(start_weapon)
	

func _fixed_process(delta):
	# aiming is currently just rotating -- should we have some sort of reticle to move around instead?
	if keyboard_mode:
		if Input.is_action_pressed("rotate_left"):
			set_rotd(get_rotd() + rotd_speed * delta)
		if Input.is_action_pressed("rotate_right"):
			set_rotd(get_rotd() + -rotd_speed * delta)
	else:
		var axis_pos = -Input.get_joy_axis(gamepad_id, JOY_AXIS_2)
		if abs(axis_pos) > joystick_idle_limit:
			set_rotd(get_rotd() + axis_pos * rotd_speed * delta)
	

func _input(event):
	if keyboard_mode:
		if event.is_action_pressed("fire_weapon"):
			_fire_weapon()
		if event.is_action_pressed("pick_up_item"):
			_pick_up_item()
	else:
		if event.is_action_pressed("joy_fire") && event.device == self.gamepad_id:
			_fire_weapon()
		if event.is_action_pressed("joy_pickup") && event.device == self.gamepad_id:
			_pick_up_item()

# handles movement
func _integrate_forces(state):
	if keyboard_mode:
		directional_force = _calculate_direction_digital(state)
	else:
		directional_force = _calculate_direction_analog(state)
	
	var final_velocity = state.get_linear_velocity() + (directional_force * acceleration)
	
	final_velocity = final_velocity.clamped(top_speed)
	
	#final_velocity.x = clamp(final_velocity.x, -top_speed, top_speed)
	#final_velocity.y = clamp(final_velocity.y, -top_speed, top_speed)
	
	state.set_linear_velocity(final_velocity)
	
	#if debug_mode: print("final speed is ", self.get_speed())

func _calculate_direction_digital(state):
	directional_force = DIRECTION.ZERO
	
	if Input.is_action_pressed("move_left"):
		directional_force += DIRECTION.LEFT
	if Input.is_action_pressed("move_right"):
		directional_force += DIRECTION.RIGHT
	if Input.is_action_pressed("move_up"):
		directional_force += DIRECTION.UP
	if Input.is_action_pressed("move_down"):
		directional_force += DIRECTION.DOWN
	
	return directional_force

func _calculate_direction_analog(state):
	directional_force = DIRECTION.ZERO
	
	var horizontal_axis_pos = Input.get_joy_axis(gamepad_id, JOY_AXIS_0)
	var vertical_axis_pos = Input.get_joy_axis(gamepad_id, JOY_AXIS_1)
	
	if abs(horizontal_axis_pos) > joystick_idle_limit:
		directional_force += horizontal_axis_pos * DIRECTION.RIGHT
	if abs(vertical_axis_pos) > joystick_idle_limit:
		directional_force += vertical_axis_pos * DIRECTION.DOWN
	
	return directional_force

func set_sprite_from_path(sprite_path):
	get_node("BodySprite").set_texture(load(sprite_path))

func connect_to_hud(manager):
	connect("health_changed", manager, "update_player_health")
	connect("died", manager, "remove_player")

func set_name(player_name):
	if debug_mode: print("name is ", player_name)
	name = player_name
	if debug_mode: print("name was set to ", name)

func set_gamepad_id(id):
	gamepad_id = id

func get_speed():
	return self.get_linear_velocity().length()

func get_speed_sq():
	return self.get_linear_velocity().length_squared()

func get_collide_damage():
	var speed_factor = self.get_speed() / speed_pain_threshold
	var dmg = speed_factor * base_collide_damage
	return dmg
	

func _detect_collision(body):
	if !body.is_in_group("Projectile") && self.is_impact_vulnerable():
		self.take_impact_damage()
	
	if body.is_in_group("SpeedDamageable"): # every speed-damageable object must have a get_speed_sq() method
		var other_speed_sq = body.get_speed_sq()
		if other_speed_sq > pow(speed_pain_threshold, 2):
			if debug_mode: print("other speed is ", self.get_speed())
			var collide_dmg = body.get_collide_damage()
			self.damage(collide_dmg)
		
	

func is_impact_vulnerable():
	return impact_vulnerable && impact_vulnerability_timer.get_time_left() > 0
	

func take_impact_damage():
	var vulnerability_factor = pow(impact_vulnerability_timer.get_time_left() / impact_vulnerability_timer.get_wait_time(), 2)
	var dmg_amount = vulnerability_factor * base_impact_damage
	
	if self.get_speed() < speed_pain_threshold:
		dmg_amount *= 0.5
	
	if debug_mode: print("player ", name, " takes ", dmg_amount, " impact damage")
	
	damage(dmg_amount)
	disable_impact_vulnerability()
	

func enable_impact_vulnerability():
	impact_vulnerability_timer.start()
	impact_vulnerable = true
	impact_vulnerable_filter.show()
	

# called when timer expires or when something is hit
func disable_impact_vulnerability():
	impact_vulnerability_timer.stop()
	impact_vulnerable = false
	impact_vulnerable_filter.hide()

func damage(dmg):
	
	health = clamp(health - dmg, 0, 100)
	#if debug_mode: print("player ", name, " takes damage ", dmg)
	emit_signal("health_changed", name, health)
	animator.play("PlayerDamaged")
	
	if health <= 0:
		emit_signal("died", name)
		queue_free()
	

func _fire_weapon():
	var spawn_pos
	if proj_spawn_positions.has(weapon.get_weapon_name()):
		spawn_pos = get_global_transform().xform (proj_spawn_positions[weapon.get_weapon_name()])
		#spawn_pos = get_global_transform().xform_inv(proj_spawn_positions[weapon.get_weapon_name()])
	else:
		spawn_pos = get_node("ProjectileSpawnPosition").get_global_pos()
	weapon.fire(spawn_pos)
	

# looks for item in pickup radius and replaces current one with it if there is
func _pick_up_item():
	var possible_items = item_detector.get_overlapping_areas()
	if debug_mode && possible_items.size() > 0: print(possible_items)
	for item in possible_items:
		if item.is_in_group("WeaponPickup"):
			_equip_weapon(item.get_player_scene())
			item.queue_free()
			break
		
		# for extensibility in case we want to add abilities
		if item.is_in_group("AbilityPickup"):
			# add ability to player/replace current one
			if debug_mode: print("found an ability")
			item.queue_free()
			break

func _equip_weapon(new_weapon_scene):
	if weapon != null:
		weapon.queue_free()
	
	weapon = new_weapon_scene.instance()
	add_child(weapon)
	#weapon.set_pos(weapon_pos)
	weapon.set_pos(weapon.get_hold_pos())
	weapon.set_rotd(weapon.get_hold_rotd())
	weapon.set_user(self)

