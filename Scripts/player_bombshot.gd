extends "res://Scripts/player_weapon.gd"

export var _arc_radius = 30.0
export var _num_projectiles = 4

var _fire_angle_incr

func _ready():
	_fire_angle_incr = 2 * _arc_radius / _num_projectiles

# _fire bombs spread over an arc
func _fire(spawn_pos):
	if FireTimer.get_time_left() > 0: return
	
	var fire_angle = -_arc_radius
	
	while fire_angle < _arc_radius:
		var projectile = projectile_scene.instance()
		projectile.global_position = spawn_pos
		projectile.global_rotation_degrees = -user.global_rotation_degrees + fire_angle
		
		#var proj_node = get_node(PROJ_SPAWN_PATH)
		if has_node(PROJ_SPAWN_PATH):
			get_node(PROJ_SPAWN_PATH).add_child(projectile)
		else:
			get_tree().get_root().add_child(projectile)
		
		fire_angle += _fire_angle_incr
	
	var rot = user.global_rotation
	var knockback_direction = Vector2(sin(rot), cos(rot)).normalized()
	var knockback_force = knockbox_strength * knockback_direction
	user.apply_impulse(Vector2(0,0), knockback_force)
	
	FireTimer.start()
	

