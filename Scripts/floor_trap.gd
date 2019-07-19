extends Area2D

export var debug_mode = false

export var using_event_system = false

export(float, 0.5, 1000.0) var damage_period = 3.0
export(float, 0.5, 1000.0) var dormant_period = 5.0 # only used if independent of events

var _is_damaging = false
export(int, 1, 1000) var damage_per_second = 25

export var _off_texture = preload("res://Sprites/Traps/floor_trap_off.png")
export var _on_texture = preload("res://Sprites/Traps/floor_trap_on.png")

var TrapSprite
var DamageTimer
var DormantTimer

func _ready():
	set_process(true)
	
	TrapSprite = get_node("TrapSprite")
	
	DamageTimer = Timer.new()
	DamageTimer.one_shot = true
	DamageTimer.wait_time = damage_period
	var connect_res = DamageTimer.connect("timeout", self, "deactivate")
	if connect_res != 0:
		printerr("Could not connect floor trap deactivate signal")
	
	DormantTimer = Timer.new()
	DormantTimer.one_shot = true
	DormantTimer.wait_time = dormant_period
	connect_res = DormantTimer.connect("timeout", self, "activate")
	if connect_res != 0:
		printerr("Could not connect floor trap activate signal")
	
	add_child(DamageTimer)
	add_child(DormantTimer)
	
	deactivate()

func _process(delta):
	if _is_damaging:
		_apply_damage(damage_per_second * delta)

func activate():
	if debug_mode:
		print("floor trap activating")
	
	_is_damaging = true
	TrapSprite.texture = _on_texture
	DamageTimer.start()

func deactivate():
	if debug_mode:
		print("floor trap deactivating")
	
	_is_damaging = false
	TrapSprite.texture = _off_texture
	
	if !using_event_system:
		DormantTimer.start()

func _apply_damage(amount):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Damageable"):
			body.damage(amount)
	

