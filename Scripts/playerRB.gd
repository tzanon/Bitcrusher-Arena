extends RigidBody2D

# in-dev modes
export var debug_mode = false

enum InputMode { GAMEPAD, KEYBOARD, KEYMOUSE }
export(InputMode) var input_mode = InputMode.GAMEPAD

var DEFAULT_EFFECT_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.effect

# gamepad device used to control this player
var _gamepad_id = -1 setget set_gamepad_id
var _player_name = "default" setget set_name

# health-related
var _health = 100
export(PackedScene) var DeathAnimation
signal health_changed(_player_name, player_health)
signal died(_player_name)

# audio-related
export var using_audio_manager = true
const DEATH_SOUND_TAG = "player_die"
const PICKUP_SOUND_TAG = "weapopn_pickup" # maybe
signal play_sound(sound_tag)

# movement-related
const JOYSTICK_IDLE_LIMIT = 0.3
export var _acceleration = 40
export var _top_speed = 300
var _rotd_speed = 270
var _directional_force = Vector2()
const DIRECTION = {
	ZERO = Vector2(0,0),
	LEFT = Vector2(-1,0),
	RIGHT = Vector2(1,0),
	UP = Vector2(0,-1),
	DOWN = Vector2(0,1)
}

# collision-related
export var _base_collide_damage = 5
export var _speed_pain_threshold = 300 # keep this for damage from other objects!
export var _base_impact_damage = 5
export var _impact_vulnerability_period = 0.3
var _impact_vulnerable
var ImpactVulnerableFilter

# node references
var Animator
var ItemDetector
var ImpactVulnerabilityTimer
var BodySprite
var AudioPlayer

# weapon-related
const START_WEAPON = preload("res://Scenes/Weapons/PlayerLaser.tscn")
var WeaponPos
var _weapon
const PROJ_SPAWN_POSITIONS = {
	"Laser" : Vector2(0, -44),
	"Potato Launcher" : Vector2(0, -40),
	"Airburst Gun" : Vector2(0, -24),
	"Bombshot" : Vector2(0, -40)
}

func _ready():
	set_physics_process(true)
	set_process_input(true)
	
	if self.connect("body_entered", self, "_detect_collision") != 0:
		printerr("could not connect collision detection signal")
	
	# getting nodes
	Animator = get_node("AnimationPlayer")
	WeaponPos = get_node("WeaponPosition").position
	ImpactVulnerableFilter = get_node("VulnerableFilter")
	BodySprite = get_node("BodySprite")
	ItemDetector = get_node("PickupDetector")
	
	# audio setup
	if connect("play_sound", AudioManager, "play_sound_by_tag") != 0:
		printerr("could not connect player to audio manager")
	if has_node("AudioStreamPlayer2D"):
		AudioPlayer = get_node("AudioStreamPlayer2D")
		AudioPlayer.stream = AudioManager.get_sound_by_tag(DEATH_SOUND_TAG)
	
	ImpactVulnerabilityTimer = get_node("VulnerableTimer")
	ImpactVulnerabilityTimer.one_shot = true
	ImpactVulnerabilityTimer.wait_time = _impact_vulnerability_period
	ImpactVulnerabilityTimer.connect("timeout", self, "disable_impact_vulnerability")
	ImpactVulnerableFilter.hide()
	_impact_vulnerable = false
	
	_equip_weapon(START_WEAPON)

func _physics_process(delta):
	# aiming is currently just rotating -- should we have some sort of reticle to move around instead?
	if input_mode == InputMode.KEYBOARD:
		if Input.is_action_pressed("rotate_left"):
			rotation_degrees = (rotation_degrees + -_rotd_speed * delta)
		if Input.is_action_pressed("rotate_right"):
			rotation_degrees = (rotation_degrees + _rotd_speed * delta)
	elif input_mode == InputMode.GAMEPAD:
		var axis_pos = Input.get_joy_axis(_gamepad_id, JOY_AXIS_2)
		if abs(axis_pos) > JOYSTICK_IDLE_LIMIT:
			rotation_degrees = rotation_degrees + axis_pos * _rotd_speed * delta
	else:
		# TODO: rotate player to face mouse pointer (begone tank controls!)
		pass

func _input(event):
	if input_mode == InputMode.KEYBOARD:
		if event.is_action_pressed("fire_weapon"):
			_fire_weapon()
		if event.is_action_pressed("pick_up_item"):
			_pick_up_item()
	elif input_mode == InputMode.GAMEPAD:
		if event.is_action_pressed("joy_fire") && event.device == self._gamepad_id:
			_fire_weapon()
		if event.is_action_pressed("joy_pickup") && event.device == self._gamepad_id:
			_pick_up_item()
	else:
		# TODO: keyboard + mouse controls
		pass

# handles movement
func _integrate_forces(state):
	if input_mode == InputMode.GAMEPAD:
		_directional_force = _calculate_direction_analog()
	else:
		_directional_force = _calculate_direction_digital()
	
	var final_velocity = state.linear_velocity + (_directional_force * _acceleration)
	
	final_velocity = final_velocity.clamped(_top_speed)
	
	state.set_linear_velocity(final_velocity)
	if debug_mode:
		#print("final speed is ", self.get_speed())
		pass

func _calculate_direction_digital():
	_directional_force = DIRECTION.ZERO
	
	if Input.is_action_pressed("move_left"):
		_directional_force += DIRECTION.LEFT
	if Input.is_action_pressed("move_right"):
		_directional_force += DIRECTION.RIGHT
	if Input.is_action_pressed("move_up"):
		_directional_force += DIRECTION.UP
	if Input.is_action_pressed("move_down"):
		_directional_force += DIRECTION.DOWN
	
	return _directional_force

func _calculate_direction_analog():
	_directional_force = DIRECTION.ZERO
	
	var horizontal_axis_pos = Input.get_joy_axis(_gamepad_id, JOY_AXIS_0)
	var vertical_axis_pos = Input.get_joy_axis(_gamepad_id, JOY_AXIS_1)
	
	if abs(horizontal_axis_pos) > JOYSTICK_IDLE_LIMIT:
		_directional_force += horizontal_axis_pos * DIRECTION.RIGHT
	if abs(vertical_axis_pos) > JOYSTICK_IDLE_LIMIT:
		_directional_force += vertical_axis_pos * DIRECTION.DOWN
	
	return _directional_force

func set_sprite_from_path(sprite_path):
	get_node("BodySprite").set_texture(load(sprite_path))

func connect_to_hud(manager):
	var health_err = connect("health_changed", manager, "update_player_health")
	var death_err = connect("died", manager, "remove_player")
	
	if health_err != 0:
		printerr("could not connect health change signal")
	if death_err != 0:
		printerr("could not connect death signal")

func set_name(new_name):
	_player_name = new_name
	if debug_mode:
		print("_player_name was set to ", _player_name)

func set_input_to_gamepad():
	input_mode = InputMode.GAMEPAD

func set_input_to_keyboard():
	input_mode = InputMode.KEYBOARD

func set_input_to_keymouse():
	input_mode = InputMode.KEYMOUSE

func set_gamepad_id(id):
	_gamepad_id = id

func get_speed():
	return self.linear_velocity.length()

func get_speed_sq():
	return self.linear_velocity.length_squared()

func _calculate_collide_damage():
	var speed_factor = self.get_speed() / _speed_pain_threshold
	var dmg = speed_factor * _base_collide_damage
	return dmg

func _detect_collision(body):
	if body.is_in_group("Projectile") and debug_mode:
		#print("hit a projectile")
		pass
	
	if !body.is_in_group("Projectile") and self.is_impact_vulnerable():
		self._take_impact_damage()
	
	if body.is_in_group("SpeedDamageable"): # every speed-damageable object must have a get_speed_sq() method
		var other_speed_sq = body.get_speed_sq()
		if other_speed_sq > pow(_speed_pain_threshold, 2):
			if debug_mode:
				print("other speed is ", self.get_speed())
			var collide_dmg = body._calculate_collide_damage()
			self.damage(collide_dmg)

func is_impact_vulnerable():
	return _impact_vulnerable and ImpactVulnerabilityTimer.time_left > 0

func _take_impact_damage():
	var vulnerability_factor = pow(ImpactVulnerabilityTimer.time_left / ImpactVulnerabilityTimer.wait_time, 2)
	var dmg_amount = vulnerability_factor * _base_impact_damage
	
	if self.get_speed() < _speed_pain_threshold:
		dmg_amount *= 0.5
	
	if debug_mode:
		print("player ", _player_name, " takes ", dmg_amount, " impact damage")
	
	damage(dmg_amount)
	disable_impact_vulnerability()

func enable_impact_vulnerability():
	ImpactVulnerabilityTimer.start()
	_impact_vulnerable = true
	ImpactVulnerableFilter.show()

# called when timer expires or when something is hit
func disable_impact_vulnerability():
	ImpactVulnerabilityTimer.stop()
	_impact_vulnerable = false
	ImpactVulnerableFilter.hide()

func damage(dmg):
	_health = clamp(_health - dmg, 0, 100)
	#if debug_mode: print("player ", _player_name, " takes damage ", dmg)
	emit_signal("health_changed", _player_name, _health)
	Animator.play("PlayerDamaged")
	
	if _health <= 0:
		_die()

func _die():
	emit_signal("died", _player_name)
	
	# spawn death anim
	var death_anim = DeathAnimation.instance()
	death_anim.position = self.global_position
	
	if has_node(DEFAULT_EFFECT_SPAWN_PATH):
		get_node(DEFAULT_EFFECT_SPAWN_PATH).add_child(death_anim)
	else:
		get_tree().get_root().add_child(death_anim)
	
	# play death sound
	if using_audio_manager:
		emit_signal("play_sound", DEATH_SOUND_TAG)
	else:
		if AudioPlayer and AudioPlayer.stream:
			AudioPlayer.play()
	
	self.queue_free()

func _fire_weapon():
	var spawn_pos
	if PROJ_SPAWN_POSITIONS.has(_weapon.get_weapon_name()):
		spawn_pos = get_global_transform().xform(PROJ_SPAWN_POSITIONS[_weapon.get_weapon_name()])
	else:
		spawn_pos = get_node("ProjectileSpawnPosition").global_position
	_weapon._fire(spawn_pos)

# looks for item in pickup radius and replaces current one with it if there is
func _pick_up_item():
	# TODO: add pickup sound?
	
	var possible_items = ItemDetector.get_overlapping_areas()
	if debug_mode && possible_items.size() > 0:
		print(possible_items)
	for item in possible_items:
		if item.is_in_group("WeaponPickup"):
			_equip_weapon(item.get_player_scene())
			item.queue_free()
			break
		
		# for extensibility in case we want to add abilities
		if item.is_in_group("AbilityPickup"):
			# add ability to player/replace current one
			if debug_mode:
				print("found an ability")
			item.queue_free()
			break

func _equip_weapon(new_weapon_scene):
	if _weapon != null:
		_weapon.queue_free()
	
	_weapon = new_weapon_scene.instance()
	add_child(_weapon)
	_weapon.position = _weapon.get_hold_pos()
	_weapon.rotation_degrees = _weapon.get_hold_rotd()
	_weapon.set_user(self)

