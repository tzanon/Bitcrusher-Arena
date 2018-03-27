extends Area2D

export var health_amount = 10

func use_pickup(user):
	# TODO: give health to user
	user.add_health(health_amount)
	self.queue_free()
