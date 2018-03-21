extends Control

export var debug_mode = false
const main_scene_path = "res://Scenes/main_menu.tscn"
export var game_scene_path = "res://Scenes/Level/level_ui_test.tscn"

onready var player_display_node = get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Picture/PlayerIcon")

var winner
var play_again_button
var main_menu_button

func _ready():
	winner = GameInfo.get_info()[0]
	_set_icon()
	
	main_menu_button = get_node("MainMargin/DisplayLayout/NavigationArea/MainMenu")
	play_again_button = get_node("MainMargin/DisplayLayout/NavigationArea/PlayAgain")
	
	play_again_button.connect("pressed", self, "_play_again")
	play_again_button.set_enabled_focus_mode(FOCUS_NONE)

	main_menu_button.connect("pressed", self, "_main_menu")
	main_menu_button.set_enabled_focus_mode(FOCUS_NONE)
	
	set_process_input(true)


func _set_icon():
	var icon = load(winner.icon_path_xl)
	print(winner.icon_path_xl)
	player_display_node.set_texture(icon)

func _input(event):
	if Input.is_joy_button_pressed(event.device, JOY_START):
		if debug_mode: print("xbox START trying to start...")
		_play_again()

	if Input.is_joy_button_pressed(event.device, JOY_XBOX_B) || Input.is_key_pressed(KEY_BACKSPACE):
		_main_menu()

func _play_again(event):
	get_tree().change_scene(main_scene_path)


func _main_menu(event):
	get_tree().change_scene(game_scene_path)
