extends Node

# contains info for current game's players; initially null
var registered_player_info = [
	{ name = "blue", pad_id = 0, head_path = "" },
	{ name = "yellow", pad_id = 1, head_path = "" }
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
