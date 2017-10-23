extends RigidBody2D

var acceleration = 100
var top_speed = 200

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
	set_mode(MODE_CHARACTER)
	set_process(true)
	item_detector = get_node("Pickup Detector")

# handles shooting and pickup input
func _process():
	
	if Input.is_action_pressed("fire_weapon"):
		# fire weapon
		pass
	
	if Input.is_action_pressed("pick_up_item"):
		pick_up_item()
	

# looks for item in pickup radius and replaces current one with it if there is
func pick_up_item():
	var bodies = item_detector.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Weapon"):
			# replace player's weapon with this one
			pass
	

# handles movement
func _integrate_forces(state):
	
	var final_force
	
	directional_force = DIRECTION.ZERO
	
	if Input.is_action_pressed("move_left"):
		directional_force += DIRECTION.LEFT
	if Input.is_action_pressed("move_right"):
		directional_force += DIRECTION.RIGHT
	if Input.is_action_pressed("move_up"):
		directional_force += DIRECTION.UP
	if Input.is_action_pressed("move_down"):
		directional_force += DIRECTION.DOWN
	
	final_force = state.get_linear_velocity() + (directional_force * acceleration)
	final_force.x = clamp(final_force.x, -top_speed, top_speed)
	final_force.y = clamp(final_force.y, -top_speed, top_speed)
	
	state.set_linear_velocity(final_force)



