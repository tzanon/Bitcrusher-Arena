extends RigidBody2D

export var debug_mode = false

# gamepad device used to control this player
var gamepad_id = -1 setget set_gamepad_id
var name = "" setget set_name

var health = 100
signal health_changed(player_name, player_health)
signal died(player_name)

var animator

const joystick_idle_limit = 0.15

export var acceleration = 40
export var top_speed = 200

var rotd_speed = 180

const start_weapon = preload("res://Scenes/Weapons/PlayerLaser.tscn")
const weapon_pos = Vector2(32, -32)
var weapon

var item_detector

var directional_force = Vector2()
const DIRECTION = {
	ZERO = Vector2(0,0),
	LEFT = Vector2(-1,0),
	RIGHT = Vector2(1,0),
	UP = Vector2(0,-1),
	DOWN = Vector2(0,1)
}

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	animator = get_node("AnimationPlayer")
	
	item_detector = get_node("Pickup Detector")
	_equip_weapon(start_weapon)
	
	var manager = get_node("/root/Level/PlayerManager")
	connect("health_changed", manager, "update_player_health")
	connect("died", manager, "remove_player")

func _fixed_process(delta):
	# aiming is currently just rotating -- should we have some sort of reticle to move around instead?
	if debug_mode:
		if Input.is_action_pressed("rotate_left"):
			set_rotd(get_rotd() + rotd_speed * delta)
		
		if Input.is_action_pressed("rotate_right"):
			set_rotd(get_rotd() + -rotd_speed * delta)
		
	else:
		var axis_pos = -Input.get_joy_axis(gamepad_id, JOY_AXIS_2)
		if abs(axis_pos) > joystick_idle_limit:
			set_rotd(get_rotd() + axis_pos * rotd_speed * delta)
	

func _input(event):
	
	if debug_mode:
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
	if debug_mode:
		directional_force = _calculate_direction_digital(state)
	else:
		directional_force = _calculate_direction_analog(state)
	
	var final_velocity = state.get_linear_velocity() + (directional_force * acceleration)
	final_velocity.x = clamp(final_velocity.x, -top_speed, top_speed)
	final_velocity.y = clamp(final_velocity.y, -top_speed, top_speed)
	state.set_linear_velocity(final_velocity)

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

func set_name(player_name):
	name = player_name

func set_gamepad_id(id):
	gamepad_id = id
	#GameInfo.print_player_name(gamepad_id)

func damage(dmg):
	health = clamp(health - dmg, 0, 100)
	if debug_mode: print("player ", name, " health: ", health)
	emit_signal("health_changed", name, health)
	animator.play("PlayerDamaged")
	
	if health <= 0:
		emit_signal("died", name)
		queue_free()
	

func _fire_weapon():
	weapon.fire()
	# TODO: recoil things
	

# looks for item in pickup radius and replaces current one with it if there is
func _pick_up_item():
	var possible_items = item_detector.get_overlapping_areas()
	if debug_mode && possible_items.size() > 0: print(possible_items)
	for item in possible_items:
		if item.is_in_group("Weapon"):
			_equip_weapon(item.get_player_scene())
			item.queue_free()
			break
		
		# for extensibility in case we want to add abilities
		if item.is_in_group("Ability"):
			# add ability to player/replace current one
			if debug_mode: print("found an ability")
			item.queue_free()
			break

func _equip_weapon(new_weapon_scene):
	if weapon != null:
		weapon.queue_free()
	
	weapon = new_weapon_scene.instance()
	add_child(weapon)
	weapon.set_pos(weapon_pos)

