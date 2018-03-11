extends KinematicBody2D

export (float) var period = 2.5
export (int) var dx = 0
export (int) var dy = 0
export (bool) var paused

var initial_pos
var time = 0
var reverse = false

func _ready():
	print(paused)
	initial_pos = get_pos()
	set_process(true)

func _process(delta):
	time += delta
	if !paused:
		var _dx = (time / period) * dx
		var _dy = (time / period) * dy
		if reverse: 
			_dx = dx - _dx
			_dy = dy - _dy
		set_pos(Vector2(initial_pos.x + _dx, initial_pos.y + _dy))
	
	if time > period:
		time = 0
		paused = !paused
		if paused: reverse = !reverse

