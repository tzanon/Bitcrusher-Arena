extends KinematicBody2D

export var debug_mode = false

export var speed = 0.0
var _movement

export var _can_deflect = true

var animator

func _ready():
	set_fixed_process(true)
	
	animator = get_node("AnimationPlayer")
	animator.connect("finished", self, "_despawn")
	
	var rot = get_global_rot()
	_movement = Vector2(sin(rot), cos(rot)) * -speed

func _fixed_process(delta):
	
	if is_colliding():
		if get_collider():
			print("arc hit ", get_collider().get_name())
	
	move(_movement * delta)

func _despawn():
	if debug_mode: print("airburst arc despawned")
	self.queue_free()

