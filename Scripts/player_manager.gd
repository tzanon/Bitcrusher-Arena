extends Node2D

# different colours? orange, purple, grey, black, brown, white?
onready var player_spawn_info = {
	"blue" : { hud_pos = Vector2(0, 0), spawn_pos = get_node("BlueSpawnPoint").get_global_pos(), sprite_path = "" },
	"red" : { hud_pos = Vector2(0, 0), spawn_pos = get_node("RedSpawnPoint").get_global_pos(), sprite_path = "" },
	"green" : { hud_pos = Vector2(0, 0), spawn_pos = get_node("GreenSpawnPoint").get_global_pos(), sprite_path = "" },
	"yellow" : { hud_pos = Vector2(0, 0), spawn_pos = get_node("YellowSpawnPoint").get_global_pos(), sprite_path = "" }
}

const player_template = preload("res://Scenes/playerRB.tscn")
const hud_template = null #= preload("")

const spawn_path = "/root/Level"


var match_player_refs = {}
var player_huds = {}

func _ready():
	
	# TODO: 
	
	# should HUDs already exist in the scene?
	# ...should we not have HUDs? just have some health indicator on players?
	
	var player_info = GameInfo.get_info()
	for info_entry in player_info:
		print("spawning player ", info_entry.name)
		#_enable_player_hud(info_entry)
		var player = _spawn_player(info_entry.name)
		player.gamepad_id = info_entry.pad_id
		match_player_refs[info_entry.name] = weakref(player)
		# connection MUST be made in player class...
	
	# this will be refactored
	var children = get_children()
	for child in children:
		if child.is_in_group("PlayerSpawnPoint"):
			child.hide()
	

func update_player_health(player_name, player_health):
	# TODO: update player's HUD with new health value
	pass

func remove_player(player_name):
	# TODO: black out icon, erase player from ref tracker, check if one remaining
	match_player_refs.erase(player_name)
	print("player ", player_name, " died.")
	
	if match_player_refs.size() == 1:
		GameInfo.match_winner = match_player_refs.keys().front()
		print("Winner is ", GameInfo.match_winner)
	
	

# WIP; do not call or it will crash
func _enable_player_hud(info_entry):
	# TODO: spawn player's respective hud at location, set icon, add to hud dictionary
	var hud = hud_template.instance() # TODO: make hud node and script
	
	player_huds[info_entry.name] = hud
	

func _spawn_player(player_name):
	# set rotation?
	var player = player_template.instance()
	player.name = player_name
	player.set_global_pos(player_spawn_info[player_name].spawn_pos)
	get_node(spawn_path).call_deferred("add_child", player)
	return player

