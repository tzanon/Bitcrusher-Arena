extends Node2D

export var refresh_interval = 10
var refresh_timer

const weapon_scenes = [
	preload("res://Scenes/Weapons/WorldLaser.tscn"),
	preload("res://Scenes/Weapons/WorldLauncher.tscn"),
	preload("res://Scenes/Weapons/WorldAirgun.tscn"),
	preload("res://Scenes/Weapons/WorldBombshot.tscn")
] # world weapon scenes to instantiate from

const light_weapon_scenes = []
const power_weapon_scenes = [] # more powerful: spawned in harder places

# TODO: exported enum and case statement to select spawn mode

export var spawn_path = "/root/Level/Layout/Pickups"
var total_spawn_points = []

var min_spawn
var max_spawn

var arena_weapon_refs # array of all weapons currently in the arena

func _ready():
	refresh_timer = get_node("RefreshTimer")
	refresh_timer.set_wait_time(refresh_interval)
	refresh_timer.set_one_shot(true)
	refresh_timer.start()
	
	var children = get_children()
	for child in children:
		if child.is_in_group("WeaponSpawnPoint"):
			child.hide()
			total_spawn_points.append(child)
	
	min_spawn = 1
	max_spawn = total_spawn_points.size()
	
	arena_weapon_refs = []
	_spawn_static_random()
	
	set_process(true)

func _process(delta):
	if refresh_timer.get_time_left() <= 0:
		_clear_weapons()
		_spawn_static_random()
		refresh_timer.start()
	

func _clear_weapons():
	#print("clearing ", arena_weapon_refs.size(), " weapons")
	for weapon_ref in arena_weapon_refs:
		if weapon_ref.get_ref():
			weapon_ref.get_ref().queue_free()
	
	arena_weapon_refs.clear()


# different ways to spawn weapons

# spawns the corresponding weapon at each position
func _spawn_static_fixed():
	for point in total_spawn_points:
		var weapon = _spawn_weapon_with_position(point)
		arena_weapon_refs.append(weakref(weapon))

# spawns a random weapon at each position
func _spawn_static_random():
	for point in total_spawn_points:
		var weapon = _spawn_random_weapon(point)
		arena_weapon_refs.append(weakref(weapon))

# randomly selects positions and spawns the corresponding weapon at each
func _spawn_select_fixed():
	var spawn_points = _select_spawn_points()
	for point in spawn_points:
		var weapon = _spawn_weapon_with_position(point)
		arena_weapon_refs.append(weakref(weapon))

# randomly selects positions and spawns a random weapon at each
func _spawn_select_random():
	var spawn_points = _select_spawn_points()
	for point in spawn_points:
		var weapon = _spawn_random_weapon(point)
		arena_weapon_refs.append(weakref(weapon))


# randomly choose n unique spawn positions
func _select_spawn_points():
	var num_weapons = randi() % (max_spawn - min_spawn + 1) + min_spawn
	var spawn_points = []
	var possible_points = [] + total_spawn_points
	
	for i in range(num_weapons):
		#print("i is ", i)
		var j = randi() % (possible_points.size())
		spawn_points.append(possible_points[j])
		possible_points.remove(j)
	
	return spawn_points


# spawns a random weapon at the given position
func _spawn_random_weapon(point):
	var i = randi() % (weapon_scenes.size())
	var weapon = weapon_scenes[i].instance()
	weapon.position = point.position
	get_node(spawn_path).call_deferred("add_child", weapon)
	return weapon

# spawns weapon at its matching position
func _spawn_weapon_with_position(point):
	var weapon = point.get_object_scene().instance()
	weapon.position = point.position
	get_node(spawn_path).call_deferred("add_child", weapon)
	return weapon	
