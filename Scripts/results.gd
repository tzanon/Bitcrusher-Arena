extends Control

onready var player_win_icons = {
	"blue" : "res://Sprites/UI/ResultsMenu/winner_blue_icon.png",
	"red" : "res://Sprites/UI/ResultsMenu/winner_red_icon.png",
	"green" : "res://Sprites/UI/ResultsMenu/winner_green_icon.png",
	"yellow" : "res://Sprites/UI/ResultsMenu/winner_yellow_icon.png"
}

export var debug_mode = false

const main_scene_path = "res://Scenes/UI/MainMenuFinal.tscn"
export var game_scene_path = "res://Scenes/Level/level_ui_test.tscn"

onready var player_display_node = get_node("MainMargin/DisplayLayout/HBoxContainer/JoinDisplays/Picture/PlayerIcon")

var winner
var play_again_button
var main_menu_button

func _ready():
	winner = GameInfo.match_winner
	_set_icon()
	
	main_menu_button = get_node("MainMargin/DisplayLayout/NavigationArea/MainMenu")
	play_again_button = get_node("MainMargin/DisplayLayout/NavigationArea/PlayAgain")
	
	play_again_button.connect("pressed", self, "_play_again")
	play_again_button.set_enabled_focus_mode(FOCUS_NONE)

	main_menu_button.connect("pressed", self, "_main_menu")
	main_menu_button.set_enabled_focus_mode(FOCUS_NONE)
	
	set_process_input(true)

func _set_icon():
	var icon = load(player_win_icons[GameInfo.match_winner])
	player_display_node.set_texture(icon)

func _input(event):
	if Input.is_joy_button_pressed(event.device, JOY_START) || Input.is_key_pressed(KEY_RETURN):
		if debug_mode: print("xbox START trying to start...")
		_play_again()

	if Input.is_joy_button_pressed(event.device, JOY_XBOX_B) || Input.is_key_pressed(KEY_BACKSPACE):
		_main_menu()

func _play_again():
	get_tree().change_scene(game_scene_path)


func _main_menu():
	get_tree().change_scene(main_scene_path)
