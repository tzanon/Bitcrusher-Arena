extends Node

# TODO: replace scene paths in other scripts with references to this dictionary
const SCENE_PATHS = {
	main_menu = "res://Scenes/UI/MainMenuFinal.tscn",
	player_select = "res://Scenes/UI/PlayerSelectMenu.tscn",
	results = "res://Scenes/UI/results.tscn",
	arena1 = "res://Scenes/Level/level_ui_test.tscn"
}

# TODO: default node paths
const NODE_SPAWN_PATHS = {
	effect = "/root/Level/Layout/Effects",
	projectile = "/root/Level/Layout/Projectiles",
	player = "/root/Level/Layout/Players",
	hud = "/root/Level/UI/PlayerInfoPanel",
	pickup = "/root/Level/Layout/Pickups"
}

# contains info for current game's players; initially null (on official release)
var registered_player_info = [
	{ name = "blue", pad_id = -1, icon_path = "res://Sprites/UI/player_blue_icon.png" },
	{ name = "red", pad_id = -1, icon_path = "res://Sprites/UI/player_red_icon.png" }
]

var match_winner = null

#debugging
func notify():
	print("singleton Global here!")

#debugging
func print_player_name(id):
	for info_entry in registered_player_info:
		if info_entry.pad_id == id:
			print(info_entry.name, " standing by!")
			break
	
func print_players():
	print("registered players: ", registered_player_info)

# refresh for a new game
func clear_info():
	match_winner = null
	registered_player_info.clear()

func get_info():
	return registered_player_info

func num_registered_players():
	return registered_player_info.size()

func register_player(info_entry):
	registered_player_info.append(info_entry)

func is_id_registered(id):
	for info_entry in registered_player_info:
		if info_entry.pad_id == id:
			return true
	
	return false

func get_player_name_with_id(id):
	for info_entry in registered_player_info:
		if info_entry.pad_id == id:
			return info_entry.name
	print("ERROR: player id ", id, " is not registered!")
	return ""
	

