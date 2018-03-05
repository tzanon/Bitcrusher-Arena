extends Area2D

export (float) var period = 1.0
export (int, 1, 100) var damage_amount = 1

var paused = false

export var off_texture = preload("res://Sprites/trap_off.png")
export var on_texture = preload("res://Sprites/trap_on.png")

var sprite
var pause_timer
var damage_timer


var flame_group1
var flame_group2
var last_flame_group

func _ready():
	sprite = get_node("TrapSprite")
	pause_timer = Timer.new()
	damage_timer = Timer.new()
	add_child(pause_timer)
	add_child(damage_timer)
	pause_timer.set_wait_time(period)
	damage_timer.set_wait_time(float(period) / (damage_amount + 1))
	pause_timer.connect("timeout", self, "_interval")
	damage_timer.connect("timeout", self, "_damage")
	pause_timer.start()
	
	flame_group1 = get_node("FlameGroup1")
	flame_group2 = get_node("FlameGroup2")
	last_flame_group = flame_group1
	flame_group1.hide()
	flame_group2.hide()
	

func _switch_flame_group():
	if flame_group1.is_visible() || !flame_group2.is_visible():
		flame_group1.hide()
		flame_group2.show()
	elif flame_group2.is_visible() || !flame_group1.is_visible():
		flame_group2.hide()
		flame_group1.show()
	

func _interval():
	paused = !paused
	if paused:
		sprite.set_texture(off_texture)
		
		if flame_group1.is_visible():
			last_flame_group = flame_group1
		elif flame_group2.is_visible():
			last_flame_group = flame_group2
		flame_group1.hide()
		flame_group2.hide()
		
		damage_timer.stop()
	if !paused: 
		sprite.set_texture(on_texture)
		
		if last_flame_group == flame_group1:
			flame_group2.show()
		elif last_flame_group == flame_group2:
			flame_group1.show()
		
		damage_timer.start()

func _damage():
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group("Damageable"):
			bodies[0].damage(1)