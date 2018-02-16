tool extends Area2D

export var debug_mode = false

export var short_range_limit = 2.0
export var med_range_limit = 4.0
export var long_range_limit = 6.0

export var burst_strength = 0.0
var push_direction
export var is_affecting = true

var burst_start_pos
var target_pos

var animator

var affected_bodies = {} # WARNING: need to clear this after a while so projectile can be bounced again (if possible)

func _ready():
	animator = get_node("AnimationPlayer")
	animator.connect("finished", self, "_despawn")
	
	#self.connect("body_enter", self, "_detect_entry")
	
	burst_start_pos = get_node("BurstStartPosition").get_pos()
	
	var rot = get_global_rot()
	push_direction = -Vector2(sin(rot), cos(rot)).normalized()
	
	if debug_mode: print("airburst spawned in tree: ", get_path())
	
	set_process(true)
	

func _process(delta):
	if !is_affecting: return
	var bodies = get_overlapping_bodies()
	for body in bodies:
		var body_name = body.get_name()
		var body_id = body.get_instance_ID()
		
		if affected_bodies.has(body_id): continue
		
		if body.get_type() == "RigidBody2D":
			if debug_mode: print("airburst pushing ", body)
			
			#burst_start_pos = get_node("BurstStartPosition").get_pos()
			target_pos = get_global_transform().xform_inv(body.get_global_pos())
			
			update()
			
			if debug_mode: print("burst start pos is ", burst_start_pos)
			if debug_mode: print("target pos is ", target_pos)
			
			# distance should be strictly vertical!
			var distance = abs(target_pos.y - burst_start_pos.y)
			if debug_mode: print("distance from airburst to target: ", distance)
			
			# check what region distance is in to get appropriate force strength
			
			var burst_force = burst_strength * push_direction
			body.apply_impulse(Vector2(0,0), burst_force)
		
		affected_bodies[body_id] = ""
	
	

func _in_range():
	
	pass

func _detect_entry(body):
	if !is_affecting: return
	
	var body_name = body.get_name()
	var body_id = body.get_instance_ID()
	
	#if !affected_bodies.has(body_id):
	if body.is_in_group("SolidProjectileKB"):
		if debug_mode: print("airburst deflecting ", body)
		#body.bounce()
	#
	
	if body.get_type() == "RigidBody2D":
		#TODO: push object
		if debug_mode: print("airburst pushing ", body)
		
		#burst_start_pos = get_node("BurstStartPosition").get_pos()
		target_pos = get_global_transform().xform_inv(body.get_global_pos())
		
		update()
		
		if debug_mode: print("burst start pos is ", burst_start_pos)
		if debug_mode: print("target pos is ", target_pos)
		
		# distance should be strictly vertical!
		var distance = abs(target_pos.y - burst_start_pos.y)
		if debug_mode: print("distance from airburst to target: ", distance)
		
		# check what region distance is in to get appropriate force strength
		
		var burst_force = burst_strength * push_direction
		body.apply_impulse(Vector2(0,0), burst_force)
		#body.apply_force(Vector2(0,0), burst_force) try both???
		
	
	#affected_bodies[body_id] = ""
	


func _draw():
	if !debug_mode: return
	
	#draw_circle(get_pos(), 28, Color("ffcb00"))
	
	if target_pos != null:
		draw_line(burst_start_pos, target_pos, Color("ffcb00"), 2.0)
	

func _despawn():
	if debug_mode: print("airburst despawned, has pushed ", affected_bodies)
	self.queue_free()

