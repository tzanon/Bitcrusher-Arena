extends Node2D

# different colours? orange, purple, grey, black, brown, white?
# will need refactoring, players will most likely need separate scenes (sprite_path)
onready var player_spawn_info = {
	"blue" : { hud_pos = Vector2(5, 0), spawn_pos = get_node("BlueSpawnPoint").get_pos(), sprite_path = "res://Sprites/Players/player_blue.png" },
	"red" : { hud_pos = Vector2(485, 0), spawn_pos = get_node("RedSpawnPoint").get_pos(), sprite_path = "res://Sprites/Players/player_red.png" },
	"green" : { hud_pos = Vector2(965, 0), spawn_pos = get_node("GreenSpawnPoint").get_pos(), sprite_path = "res://Sprites/Players/player_green.png" },
	"yellow" : { hud_pos = Vector2(1445, 0), spawn_pos = get_node("YellowSpawnPoint").get_pos(), sprite_path = "res://Sprites/Players/player_yellow.png" }
}

export var debug_mode = false

const player_template = preload("res://Scenes/Player.tscn")
const hud_template = preload("res://Scenes/UI/PlayerInfoUI.tscn")

export var spawn_path = "/root/Level/Layout/Players"
export var hud_spawn_path = "/root/Level/UI/PlayerInfoPanel"

var match_player_refs = {}
var player_huds = {}

func _ready():
	var player_info = GameInfo.get_info()
	for info_entry in player_info:
		if debug_mode: print("spawning player ", info_entry.name)
		
		_enable_player_hud(info_entry) # setup hud for current player
		
		var player = _spawn_player(info_entry.name)
		player.gamepad_id = info_entry.pad_id
		match_player_refs[info_entry.name] = weakref(player)
	
	# this will be refactored (or not)
	var children = get_children()
	for child in children:
		if child.is_in_group("PlayerSpawnPoint"):
			child.hide()
	

func _spawn_player(player_name):
	# set rotation?
	var player = player_template.instance()
	player.connect_to_hud(self)
	
	player.set_name(player_name)
	player.set_sprite_from_path(player_spawn_info[player_name].sprite_path)
	player.set_global_pos(player_spawn_info[player_name].spawn_pos)
	get_node(spawn_path).call_deferred("add_child", player)
	
	return player


func remove_player(player_name):
	if debug_mode: print("player ", player_name, " died.")
	
	match_player_refs.erase(player_name)
	player_huds[player_name].set_death_icon()
	
	if match_player_refs.size() == 1:
		_end_game()

func _enable_player_hud(info_entry):
	var hud = hud_template.instance()
	
	get_node(hud_spawn_path).call_deferred("add_child", hud)
	hud.call_deferred("set_icon_with_path", info_entry.icon_path)
	
	var position = player_spawn_info[info_entry.name].hud_pos
	hud.set_pos(position)
	
	player_huds[info_entry.name] = hud
	

func update_player_health(player_name, player_health):
	if debug_mode: print("player name is ", player_name, " with health ", player_health)
	var hud = player_huds[player_name]
	hud.update_health(player_health)

func _end_game():
	GameInfo.match_winner = match_player_refs.keys().front()
	if debug_mode: print("Winner is ", GameInfo.match_winner)
	get_tree().change_scene("res://Scenes/UI/results.tscn")
	
