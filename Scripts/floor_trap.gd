extends Area2D

export (int) var damage_amount = 0
export (float) var period = 1

var off_texture = preload("res://Sprites/trap_off.png")
var on_texture = preload("res://Sprites/trap_on.png")
var sprite

var time = 0
var paused = false

func _ready():
	sprite = get_node("Sprite")
	set_fixed_process(true)

func _fixed_process(delta):
	time += delta
	if time > period:
		time = 0
		paused = !paused
		if paused: sprite.set_texture(off_texture)
		if !paused: sprite.set_texture(on_texture)

	if !paused:
		var bodies = get_overlapping_bodies()
		if bodies.size() > 0:
			if bodies[0].is_in_group("Damageable"):
				bodies[0].damage(damage_amount * delta)
