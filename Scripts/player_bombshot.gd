extends "res://Scripts/player_weapon.gd"

export var arc_radius = 30.0
export var num_projectiles = 4

var fire_angle_incr

func _ready():
	fire_angle_incr = 2 * arc_radius / num_projectiles

# fire bombs spread over an arc
func fire(spawn_pos):
	if fire_timer.get_time_left() > 0: return
	
	var fire_angle = -arc_radius
	
	while fire_angle < arc_radius:
		var projectile = projectile_scene.instance()
		projectile.global_position = spawn_pos
		projectile.global_rotation_degrees = -user.global_rotation_degrees + fire_angle
		
		var proj_node = get_node(proj_spawn_path)
		if proj_node:
			get_node(proj_spawn_path).add_child(projectile)
		else:
			get_tree().get_root().add_child(projectile)
		
		fire_angle += fire_angle_incr
	
	var rot = user.global_rotation
	var knockback_direction = Vector2(sin(rot), cos(rot)).normalized()
	var knockback_force = knockbox_strength * knockback_direction
	user.apply_impulse(Vector2(0,0), knockback_force)
	
	fire_timer.start()
	

