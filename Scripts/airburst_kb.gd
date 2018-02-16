extends KinematicBody2D

export var debug_mode = false

export var burst_strength = 0.0
export var is_affecting = true

var push_direction

var animator

var affected_bodies = {}

func _ready():
	set_fixed_process(true)
	
	animator = get_node("AnimationPlayer")
	#animator.connect("finished", self, "_despawn")
	
	var rot = get_global_rot()
	push_direction = Vector2(sin(rot), cos(rot)).normalized()
	
	if debug_mode: print("airburst spawned")
	

func _fixed_process(delta):
	if is_colliding(): #&& is_affecting:
		if debug_mode: print("airburst hit something")
		var body = get_collider()
		if body.get_type() == "RigidBody2D":
			if debug_mode: print("airburst pushing ", body.get_name())
			
	

func _despawn():
	if debug_mode: print("airburst despawned, has pushed ", affected_bodies)
	self.queue_free()

