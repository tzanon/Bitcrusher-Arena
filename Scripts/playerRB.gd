extends RigidBody2D

var acceleration = 100
var top_speed = 200

var rotd_speed = 180

const START_WEAPON = preload("res://Scenes/Weapons/player_orange_ph.tscn")
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
	set_process_input(true)
	set_fixed_process(true)
	
	item_detector = get_node("Pickup Detector")
	_equip_weapon(START_WEAPON)
	

func _fixed_process(delta):
	if Input.is_action_pressed("rotate_left"):
		set_rotd(get_rotd() + rotd_speed * delta)
	if Input.is_action_pressed("rotate_right"):
		set_rotd(get_rotd() + -rotd_speed * delta)
	

func _input(event):
	if Input.is_action_pressed("fire_weapon"):
		_fire_weapon()
	
	if Input.is_action_pressed("pick_up_item"):
		_pick_up_item()

func _fire_weapon():
	weapon.fire()

# looks for item in pickup radius and replaces current one with it if there is
func _pick_up_item():
	print("looking...")
	var possible_items = item_detector.get_overlapping_areas()
	if possible_items.size() > 0: print(possible_items)
	for item in possible_items:
		if item.is_in_group("Weapon"):
			_equip_weapon(item.player_weapon_scene)
			print("got weapon ", weapon)
			item.queue_free()
			break
		
		# for extensibility in case we want to add abilities
		if item.is_in_group("Ability"):
			# add ability to player/replace current one
			print("found an ability")
			item.queue_free()
			break
	

func _equip_weapon(new_weapon_scene):
	if weapon != null:
		weapon.queue_free()
	
	weapon = new_weapon_scene.instance()
	add_child(weapon)
	weapon.set_pos(weapon_pos)
	

# handles movement
func _integrate_forces(state):
	var final_velocity
	directional_force = DIRECTION.ZERO
	
	if Input.is_action_pressed("move_left"):
		directional_force += DIRECTION.LEFT
	if Input.is_action_pressed("move_right"):
		directional_force += DIRECTION.RIGHT
	if Input.is_action_pressed("move_up"):
		directional_force += DIRECTION.UP
	if Input.is_action_pressed("move_down"):
		directional_force += DIRECTION.DOWN
	
	final_velocity = state.get_linear_velocity() + (directional_force * acceleration)
	final_velocity.x = clamp(final_velocity.x, -top_speed, top_speed)
	final_velocity.y = clamp(final_velocity.y, -top_speed, top_speed)
	state.set_linear_velocity(final_velocity)
	
	



