extends Node2D

export var debug_mode = false

export var _refresh_interval = 10
var RefreshTimer

const WEAPON_SCENES = [
	preload("res://Scenes/Weapons/WorldLaser.tscn"),
	preload("res://Scenes/Weapons/WorldLauncher.tscn"),
	preload("res://Scenes/Weapons/WorldAirgun.tscn"),
	preload("res://Scenes/Weapons/WorldBombshot.tscn")
] # world weapon scenes to instantiate from

# TODO: exported enum and case statement to select spawn mode

enum SpawnMode {STATIC_FIXED, STATIC_RANDOM, SELECT_FIXED, SELECT_RANDOM}
export(SpawnMode) var _initial_spawn_mode = 1

# funcref to the current spawn function
var _spawn_func_ref = funcref(self, "_spawn_static_random")

var DEFAULT_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.pickup #"/root/Level/Layout/Pickups"
var _total_spawn_points = []

var _min_spawn
var _max_spawn

var _arena_weapon_refs # array of all weapons currently in the arena

func _ready():
	var children = get_children()
	for child in children:
		if child.is_in_group("WeaponSpawnPoint"):
			child.hide()
			_total_spawn_points.append(child)
	
	_min_spawn = 1
	_max_spawn = _total_spawn_points.size()
	
	_arena_weapon_refs = []
	# TODO: spawn weapons with preferred method
	enable_spawn_mode(_initial_spawn_mode)
	_spawn_func_ref.call_func()
	
	RefreshTimer = get_node("RefreshTimer")
	RefreshTimer.wait_time = _refresh_interval
	RefreshTimer.connect("timeout", self, "drop_new_weapons")
	RefreshTimer.start()
	

func drop_new_weapons():
	clear_weapons()
	_spawn_func_ref.call_func()
	

func clear_weapons():
	if debug_mode:
		print("clearing ", _arena_weapon_refs.size(), " weapons")
	
	if _arena_weapon_refs.size() <= 0:
		return
	
	for weapon_ref in _arena_weapon_refs:
		if weapon_ref.get_ref():
			weapon_ref.get_ref().queue_free()
	
	_arena_weapon_refs.clear()
	

# enable the desired spawn mode
func enable_spawn_mode(mode):
	if mode == SpawnMode.STATIC_FIXED:
		_spawn_func_ref.set_function("_spawn_static_fixed")
	elif mode == SpawnMode.SELECT_FIXED:
		_spawn_func_ref.set_function("_spawn_select_fixed")
	elif mode == SpawnMode.SELECT_RANDOM:
		_spawn_func_ref.set_function("_spawn_select_random")
	else: # if mode is 1 or not recognized, default to static random
		_spawn_func_ref.set_function("_spawn_static_random")
	

# different ways to spawn weapons

# spawns the corresponding weapon at each position
func _spawn_static_fixed():
	for point in _total_spawn_points:
		var weapon = _spawn_default_weapon(point)
		_arena_weapon_refs.append(weakref(weapon))

# spawns a random weapon at each position
func _spawn_static_random():
	for point in _total_spawn_points:
		var weapon = _spawn_random_weapon(point)
		_arena_weapon_refs.append(weakref(weapon))

# randomly selects positions and spawns the corresponding weapon at each
func _spawn_select_fixed():
	var spawn_points = _select_spawn_points()
	for point in spawn_points:
		var weapon = _spawn_default_weapon(point)
		_arena_weapon_refs.append(weakref(weapon))

# randomly selects positions and spawns a random weapon at each
func _spawn_select_random():
	var spawn_points = _select_spawn_points()
	for point in spawn_points:
		var weapon = _spawn_random_weapon(point)
		_arena_weapon_refs.append(weakref(weapon))


# randomly choose n unique spawn positions
func _select_spawn_points():
	var num_weapons = randi() % (_max_spawn - _min_spawn + 1) + _min_spawn
	var spawn_points = []
	var possible_points = [] + _total_spawn_points
	
	for i in range(num_weapons):
		#print("i is ", i)
		var j = randi() % (possible_points.size())
		spawn_points.append(possible_points[j])
		possible_points.remove(j)
	
	return spawn_points


# spawns a random weapon at the given position
func _spawn_random_weapon(point):
	var i = randi() % (WEAPON_SCENES.size())
	var weapon = WEAPON_SCENES[i].instance()
	return _spawn_weapon(weapon, point)

# spawns weapon at its matching position
func _spawn_default_weapon(point):
	var weapon = point.get_object_scene().instance()
	return _spawn_weapon(weapon, point)

# spawn weapon at given point
func _spawn_weapon(weapon, point):
	weapon.position = point.position
	if has_node(DEFAULT_SPAWN_PATH):
		get_node(DEFAULT_SPAWN_PATH).call_deferred("add_child", weapon)
	else:
		get_tree().get_root().call_deferred("add_child", weapon)
	
	return weapon
	
