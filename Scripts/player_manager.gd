extends Node2D

onready var _player_spawn_info = {
	"blue" : { hud_pos = Vector2(5, 0), spawn_pos = get_node("BlueSpawnPoint").position, sprite_path = "res://Sprites/Players/player_blue.png" },
	"red" : { hud_pos = Vector2(485, 0), spawn_pos = get_node("RedSpawnPoint").position, sprite_path = "res://Sprites/Players/player_red.png" },
	"green" : { hud_pos = Vector2(965, 0), spawn_pos = get_node("GreenSpawnPoint").position, sprite_path = "res://Sprites/Players/player_green.png" },
	"yellow" : { hud_pos = Vector2(1445, 0), spawn_pos = get_node("YellowSpawnPoint").position, sprite_path = "res://Sprites/Players/player_yellow.png" }
}

export var debug_mode = false

export var spawn_keyboard_player = false
onready var keyboard_player_spawn_point = get_node("TestSpawnPoint").position

const PlayerTemplate = preload("res://Scenes/Player.tscn")
const HudTemplate = preload("res://Scenes/UI/PlayerInfoUI.tscn")

const DEFAULT_PLAYER_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.player # "/root/Level/Layout/Players"
const DEFAULT_HUD_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.hud # "/root/Level/UI/PlayerInfoPanel"

export var _game_end_time = 3.0
var EndTimer

var _match_player_refs = {}
var _player_huds = {}

func _ready():
	# time after last player's death before displaying results
	EndTimer = get_node("EndTimer")
	EndTimer.wait_time = _game_end_time
	EndTimer.one_shot = true
	EndTimer.connect("timeout", self, "_show_results")
	
	if (spawn_keyboard_player):
		var test_player = PlayerTemplate.instance()
		test_player.set_input_to_keyboard()
		test_player.set_name("keyboard tester")
		test_player.global_position = keyboard_player_spawn_point
		get_node(DEFAULT_PLAYER_SPAWN_PATH).call_deferred("add_child", test_player)
	
	var player_info = GameInfo.get_info()
	for info_entry in player_info:
		if debug_mode:
			print("spawning player ", info_entry.name)
		
		_enable_player_hud(info_entry) # setup hud for current player
		
		var player = _spawn_player(info_entry.name)
		player.set_gamepad_id(info_entry.pad_id)
		_match_player_refs[info_entry.name] = weakref(player)
	
	# this will be refactored (or not)
	var children = get_children()
	for child in children:
		if child.is_in_group("PlayerSpawnPoint"):
			child.hide()

func _spawn_player(player_name):
	var player = PlayerTemplate.instance()
	player.connect_to_hud(self)
	
	player.set_name(player_name)
	player.set_sprite_from_path(_player_spawn_info[player_name].sprite_path)
	player.global_position = _player_spawn_info[player_name].spawn_pos
	get_node(DEFAULT_PLAYER_SPAWN_PATH).call_deferred("add_child", player)
	
	return player

func remove_player(player_name):
	if debug_mode:
		print("player ", player_name, " died.")
	
	_match_player_refs.erase(player_name)
	_player_huds[player_name].set_death_icon()
	
	if _match_player_refs.size() == 1:
		_end_game()

func _enable_player_hud(info_entry):
	var hud = HudTemplate.instance()
	
	get_node(DEFAULT_HUD_SPAWN_PATH).call_deferred("add_child", hud)
	hud.call_deferred("set_icon_with_path", info_entry.icon_path)
	
	var hud_position = _player_spawn_info[info_entry.name].hud_pos
	hud.rect_position = hud_position
	
	_player_huds[info_entry.name] = hud
	

func update_player_health(player_name, player_health):
	if debug_mode:
		print("player name is ", player_name, " with health ", player_health)
	var hud = _player_huds[player_name]
	hud.update_health(player_health)

func _end_game():
	GameInfo.match_winner = _match_player_refs.keys().front()
	if debug_mode:
		print("Winner is ", GameInfo.match_winner)
	EndTimer.start()
	

func _show_results():
	get_tree().change_scene(GameInfo.SCENE_PATHS.results)
