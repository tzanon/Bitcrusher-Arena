extends KinematicBody2D

export (float) var _period = 2.5
export (int) var _speed_factor_x = 0
export (int) var _speed_factor_y = 0
export (bool) var _paused

var _initial_pos
var _time = 0
var _reverse = false

func _ready():
	print(_paused)
	_initial_pos = self.position
	set_process(true)

func _process(delta):
	_time += delta
	if !_paused:
		var x_pos_incr = (_time / _period) * _speed_factor_x
		var y_pos_incr = (_time / _period) * _speed_factor_y
		if _reverse: 
			x_pos_incr = _speed_factor_x - x_pos_incr
			y_pos_incr = _speed_factor_y - y_pos_incr
		self.position = (Vector2(_initial_pos.x + x_pos_incr, _initial_pos.y + y_pos_incr))
	
	if _time > _period:
		_time = 0
		_paused = !_paused
		if _paused: _reverse = !_reverse

func get_speed():
	return 0

func get_speed_sq():
	return 0

func get_impact_damage():
	return 0

