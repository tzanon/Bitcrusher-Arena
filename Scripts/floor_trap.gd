extends Area2D

export (float) var _period = 1.0
export (int, 1, 100) var _damage_amount = 1

var _paused = false

export var _off_texture = preload("res://Sprites/Traps/floor_trap_off.png")
export var _on_texture = preload("res://Sprites/Traps/floor_trap_on.png")

var Sprite
var PauseTimer
var DamageTimer

var FlameGroup1
var FlameGroup2
var LastFlameGroup

func _ready():
	Sprite = get_node("TrapSprite")
	PauseTimer = Timer.new()
	DamageTimer = Timer.new()
	add_child(PauseTimer)
	add_child(DamageTimer)
	PauseTimer.wait_time = _period
	DamageTimer.wait_time = float(_period) / (_damage_amount + 1)
	PauseTimer.connect("timeout", self, "_interval")
	DamageTimer.connect("timeout", self, "_damage")
	PauseTimer.start()
	
	FlameGroup1 = get_node("FlameGroup1")
	FlameGroup2 = get_node("FlameGroup2")
	LastFlameGroup = FlameGroup1
	FlameGroup1.hide()
	FlameGroup2.hide()
	

func _switch_flame_group():
	if FlameGroup1.is_visible() || !FlameGroup2.is_visible():
		FlameGroup1.hide()
		FlameGroup2.show()
	elif FlameGroup2.is_visible() || !FlameGroup1.is_visible():
		FlameGroup2.hide()
		FlameGroup1.show()
	

func _interval():
	_paused = !_paused
	if _paused:
		Sprite.set_texture(_off_texture)
		
		if FlameGroup1.is_visible():
			LastFlameGroup = FlameGroup1
		elif FlameGroup2.is_visible():
			LastFlameGroup = FlameGroup2
		FlameGroup1.hide()
		FlameGroup2.hide()
		
		DamageTimer.stop()
	if !_paused: 
		Sprite.set_texture(_on_texture)
		
		if LastFlameGroup == FlameGroup1:
			FlameGroup2.show()
		elif LastFlameGroup == FlameGroup2:
			FlameGroup1.show()
		
		DamageTimer.start()

func _damage():
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group("Damageable"):
			bodies[0].damage(1)