extends Control

export var debug_mode = false
export var solo_test_mode = false

const main_menu_path = "res://Scenes/UI/MainMenuFinal.tscn"
export var game_scene_path = "res://Scenes/level.tscn"

const default_icon = preload("res://Sprites/Placeholder/ui_icon1.png")
const id_prompt = preload("res://Sprites/UI/SelectMenu/id_prompt.png")

export(PackedScene) var player_id_scene

var player_info = [
	{ name = "blue", pad_id = -1, icon_path = "res://Sprites/UI/player_blue_icon.png" },
	{ name = "red", pad_id = -1, icon_path = "res://Sprites/UI/player_red_icon.png" },
	{ name = "green", pad_id = -1, icon_path = "res://Sprites/UI/player_green_icon.png" },
	{ name = "yellow", pad_id = -1, icon_path = "res://Sprites/UI/player_yellow_icon.png" }
]

onready var player_display_nodes = {
	"blue" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display1"),
	"red" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display2"),
	"green" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display3"),
	"yellow" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display4")
}

onready var player_prompt_nodes = {
	"blue" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display1/PlayerJoin"),
	"red" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display2/PlayerJoin"),
	"green" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display3/PlayerJoin"),
	"yellow" : get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Display4/PlayerJoin")
}

var player_warning
var back_button
var start_button

func _ready():
	GameInfo.clear_info()
	
	if solo_test_mode:
		_request_join(1) # add one "dummy" player to proceed with one gamepad
	
	player_warning = get_node("MainMargin/PlayerWarning")
	back_button = get_node("MainMargin/DisplayLayout/NavigationArea/BackButton")
	start_button = get_node("MainMargin/DisplayLayout/NavigationArea/StartButton")
	
	player_warning.hide()
	
	back_button.connect("pressed", self, "_back")
	back_button.set_enabled_focus_mode(FOCUS_NONE)
	
	start_button.connect("pressed", self, "_request_start_game")
	start_button.set_enabled_focus_mode(FOCUS_NONE)
	
	set_process_input(true)

func _input(event):
	if Input.is_key_pressed(KEY_RETURN):
		if debug_mode: print("start key was pressed")
		if player_warning.is_visible():
			player_warning.hide()
			if debug_mode: print("warning is now hidden")
		else:
			if debug_mode: print("trying to start...")
			_request_start_game()
	
	if Input.is_joy_button_pressed(event.device, JOY_XBOX_A): #JOY_XBOX_A == JOY_BUTTON_0
		if debug_mode: print("xbox A was pressed")
		if player_warning.is_visible():
			player_warning.hide()
			if debug_mode: print("warning is now hidden")
		else:
			_request_join(event.device)
	
	if Input.is_joy_button_pressed(event.device, JOY_XBOX_B) || Input.is_key_pressed(KEY_BACKSPACE):
		if player_warning.is_visible():
			player_warning.hide()
			if debug_mode: print("warning is now hidden")
		else:
			_back()
	
	if Input.is_joy_button_pressed(event.device, JOY_START):
		if debug_mode: print("xbox START trying to start...")
		_request_start_game()
	

func _back():
	if debug_mode: print("returning to menu")
	get_tree().change_scene(main_menu_path)

func _set_icon(info_entry):
	var icon_node = player_display_nodes[info_entry.name].get_node("IconBack/PlayerIcon")
	var icon = load(info_entry.icon_path)
	icon_node.set_texture(icon)

func _clear_icon(info_entry):
	var icon_node = player_display_nodes[info_entry.name].get_node("IconBack/PlayerIcon")
	icon_node.set_texture(default_icon)

func _set_id_prompt(info_entry):
	var prompt_node = player_display_nodes[info_entry.name].get_node("PlayerJoin")
	prompt_node.set_texture(id_prompt)

func _request_join(gamepad_id):
	if GameInfo.is_id_registered(gamepad_id):
		# do something with player's icon
		# shoot laser out of side maybe
		var player_name = GameInfo.get_player_name_with_id(gamepad_id)
		var display_node = player_display_nodes[player_name].get_node("IconBack/PlayerIcon")
		
		var id_demo = player_id_scene.instance()
		id_demo.set_pos(display_node.get_global_pos() + Vector2(120, 50))
		id_demo.set_rotd(-90)
		get_tree().get_root().add_child(id_demo)
		
		if debug_mode: print("controller ", gamepad_id, " is already registered")
	else:
		_register_gamepad(gamepad_id)
		if debug_mode: print("controller ", gamepad_id, " registered")

func _register_gamepad(gamepad_id):
	if player_info.size() == 0:
		return
	
	var info_entry = player_info.front()
	player_info.pop_front()
	info_entry.pad_id = gamepad_id
	GameInfo.register_player(info_entry)
	
	# set icon and change join prompt text
	_set_icon(info_entry)
	_set_id_prompt(info_entry)
	
	GameInfo.print_players()
	if debug_mode: print("remaining players: ", player_info)
	

func _request_start_game():
	if GameInfo.num_registered_players() < 2:
		if debug_mode: print("At least 2 players needed to play")
		# briefly show "need more players" message
		player_warning.popup()
	else:
		if debug_mode: print("starting game")
		# change scene? autoloader?
		get_tree().change_scene(game_scene_path)
		pass
	
