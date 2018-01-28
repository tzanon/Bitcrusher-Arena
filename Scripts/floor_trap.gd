extends Area2D

export (float) var period = 1.0
export (int, 1, 100) var damage_amount = 1

var paused = false

var off_texture = preload("res://Sprites/trap_off.png")
var on_texture = preload("res://Sprites/trap_on.png")
var sprite
var pause_timer
var damage_timer


func _ready():
	sprite = get_node("Sprite")
	pause_timer = Timer.new()
	damage_timer = Timer.new()
	add_child(pause_timer)
	add_child(damage_timer)
	pause_timer.set_wait_time(period)
	damage_timer.set_wait_time(float(period) / (damage_amount + 1))
	pause_timer.connect("timeout", self, "_interval")
	damage_timer.connect("timeout", self, "_damage")
	pause_timer.start()
	set_fixed_process(true)
	

func _interval():
	paused = !paused
	if paused: sprite.set_texture(off_texture)
		damage_timer.stop()
	if !paused: 
		sprite.set_texture(on_texture)
		damage_timer.start()

func _damage():
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group("Damageable"):
			bodies[0].damage(1)