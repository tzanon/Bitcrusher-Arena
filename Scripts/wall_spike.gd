extends RigidBody2D

export var debug_mode = false

export(int) var _damage_amount = 5

func _ready():
	self.connect("body_entered", self, "_handle_collision")

func _handle_collision(body):
	if body.is_in_group("Damageable"):
		if debug_mode:
			print("spike damaging ", body.name)
		body.damage(_damage_amount)
	
