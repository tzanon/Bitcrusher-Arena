extends Area2D

export var _raycast_range = 60
var ObstructionDetectCast

var raycast_info_list = []
var raycast_info = { target_pos = Vector2(), end_pos = Vector2() }

# Called when the node enters the scene tree for the first time.
func _ready():
	ObstructionDetectCast = $RayCast2D
	ObstructionDetectCast.enabled = true
	
	self.connect("body_entered", self, "_is_target_obstructed")
	_check_for_obstructions()

func _draw():
	_draw_raycasts()

# draw lines representing the raycasts to detected damagable objects
func _draw_raycasts():
	for info in raycast_info_list:
		draw_line(Vector2(), info.end_pos, Color.green, 6.0) # draw full cast
		draw_line(Vector2(), info.target_pos, Color.purple, 6.0) # draw line to target

# determine if anything in front of damagable objects
func _check_for_obstructions():
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Damageable") and !_is_target_obstructed(body):
			print("explosion would damage the target ", body)

# determine if there is an object between the explosion and target
func _is_target_obstructed(target):
	if !target.is_in_group("Damageable"):
		return
	
	var unscaled_direction = target.global_position-self.global_position
	var direction = unscaled_direction.normalized()
	var cast_vec = _raycast_range * direction
	
	ObstructionDetectCast.cast_to = cast_vec
	var coll = ObstructionDetectCast.get_collider()
	
	# if RC finds target or nothing (somehow), no obstruction
	var is_obstructed
	var rc_info = { target_pos = Vector2(), end_pos = cast_vec }
	
	var game_time = OS.get_unix_time() - GameInfo.game_start_time
	
	if coll == null:
		print("ERC ", game_time, ": raycast detected nothing/NULL in direction of ", target.name)
		is_obstructed = false
	else:
		var hit_pos_global = ObstructionDetectCast.get_collision_point()
		var hit_pos_local = self.to_local(hit_pos_global)
		rc_info.target_pos = hit_pos_local
		
		if coll == target:
			print("ERC ", game_time, ": nothing obstructing ", target.name)
			is_obstructed = false
		else: # if it finds something else in front of the target, it is obstructed
			print("ERC ", game_time, ": ", target.name, " is blocked by ", coll.name)
			is_obstructed = true
	
	raycast_info_list.append(rc_info)
	self.update() # update debug lines
	return is_obstructed
