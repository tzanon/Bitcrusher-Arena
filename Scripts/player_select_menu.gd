extends Control

export var debug_mode = false
export var solo_test_mode = false

const DEFAULT_ICON = preload("res://Sprites/Placeholder/ui_icon1.png")
const ID_PROMPT = preload("res://Sprites/UI/SelectMenu/ID_PROMPT.png")

export(PackedScene) var _player_id_scene

var _player_info = [
	{ name = "blue", pad_id = -1, icon_path = "res://Sprites/UI/player_blue_icon.png" },
	{ name = "red", pad_id = -1, icon_path = "res://Sprites/UI/player_red_icon.png" },
	{ name = "green", pad_id = -1, icon_path = "res://Sprites/UI/player_green_icon.png" },
	{ name = "yellow", pad_id = -1, icon_path = "res://Sprites/UI/player_yellow_icon.png" }
]

onready var _player_display_nodes = {
	"blue" : get_node("Layout/JoinDisplays/Display1"),
	"red" : get_node("Layout/JoinDisplays/Display2"),
	"green" : get_node("Layout/JoinDisplays/Display3"),
	"yellow" : get_node("Layout/JoinDisplays/Display4")
}

var PlayerWarning
var BackButton
var StartButton

func _ready():
	GameInfo.clear_info()
	
	if solo_test_mode:
		_request_join(1) # add one "dummy" player to proceed with one gamepad
	
	PlayerWarning = get_node("Layout/PlayerWarning")
	BackButton = get_node("Layout/BackButton")
	StartButton = get_node("Layout/StartButton")
	
	PlayerWarning.hide()
	
	BackButton.connect("pressed", self, "_back")
	BackButton.enabled_focus_mode = FOCUS_NONE
	
	StartButton.connect("pressed", self, "_request_start_game")
	StartButton.enabled_focus_mode = FOCUS_NONE
	
	set_process_input(true)

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		if debug_mode:
			print("start key was pressed")
		if PlayerWarning.is_visible():
			PlayerWarning.hide()
			if debug_mode:
				print("warning is now hidden")
		else:
			if debug_mode:
				print("trying to start...")
			_request_start_game()
	
	if Input.is_joy_button_pressed(event.device, JOY_XBOX_A): #JOY_XBOX_A == JOY_BUTTON_0
		if debug_mode:
			print("xbox A was pressed")
		if PlayerWarning.is_visible():
			PlayerWarning.hide()
			if debug_mode:
				print("warning is now hidden")
		else:
			_request_join(event.device)
	
	if Input.is_joy_button_pressed(event.device, JOY_XBOX_B) || Input.is_key_pressed(KEY_BACKSPACE):
		if PlayerWarning.is_visible():
			PlayerWarning.hide()
			if debug_mode:
				print("warning is now hidden")
		else:
			_back()
	
	if Input.is_joy_button_pressed(event.device, JOY_START):
		if debug_mode:
			print("xbox START trying to start...")
		_request_start_game()
	

func _back():
	if debug_mode:
		print("returning to menu")
	get_tree().change_scene(GameInfo.SCENE_PATHS.main_menu)

func _set_icon(info_entry):
	var icon_node = _player_display_nodes[info_entry.name].get_node("IconBack/PlayerIcon")
	var icon = load(info_entry.icon_path)
	icon_node.set_texture(icon)

func _clear_icon(info_entry):
	var icon_node = _player_display_nodes[info_entry.name].get_node("IconBack/PlayerIcon")
	icon_node.set_texture(DEFAULT_ICON)

func _set_id_prompt(info_entry):
	var prompt_node = _player_display_nodes[info_entry.name].get_node("PlayerJoin")
	prompt_node.set_texture(ID_PROMPT)

func _request_join(gamepad_id):
	if GameInfo.is_id_registered(gamepad_id):
		# do something with player's icon
		# shoot laser out of side maybe
		var player_name = GameInfo.get_player_name_with_id(gamepad_id)
		var display_node = _player_display_nodes[player_name].get_node("IconBack/PlayerIcon")
		
		# TODO: play unique sound for each player
		
		var id_demo = _player_id_scene.instance()
		id_demo.position = display_node.rect_global_position + Vector2(120, 50)
		id_demo.rotation_degrees = 90
		get_tree().get_root().add_child(id_demo)
		
		if debug_mode:
			print("controller ", gamepad_id, " is already registered")
	else:
		_register_gamepad(gamepad_id)
		if debug_mode:
			print("controller ", gamepad_id, " registered")

func _register_gamepad(gamepad_id):
	if _player_info.size() == 0:
		return
	
	var info_entry = _player_info.front()
	_player_info.pop_front()
	info_entry.pad_id = gamepad_id
	GameInfo.register_player(info_entry)
	
	# set icon and change join prompt text
	_set_icon(info_entry)
	_set_id_prompt(info_entry)
	
	GameInfo.print_players()
	if debug_mode:
		print("remaining players: ", _player_info)

func _request_start_game():
	if GameInfo.num_registered_players() < 2:
		if debug_mode:
			print("At least 2 players needed to play")
		# briefly show "need more players" message
		PlayerWarning.popup()
	else:
		if debug_mode:
			print("starting game")
		get_tree().change_scene(GameInfo.SCENE_PATHS.arena1)
	
