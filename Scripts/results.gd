extends Control

const PLAYER_WIN_ICONS = {
	"blue" : "res://Sprites/UI/ResultsMenu/winner_blue_icon.png",
	"red" : "res://Sprites/UI/ResultsMenu/winner_red_icon.png",
	"green" : "res://Sprites/UI/ResultsMenu/winner_green_icon.png",
	"yellow" : "res://Sprites/UI/ResultsMenu/winner_yellow_icon.png",
	"default" : "res://Sprites/UI/player_default_icon.png"
}

export var debug_mode = false

onready var PlayerDisplayNode = get_node("Picture/PlayerIcon")

var PlayAgainButton
var MainMenuButton

func _ready():
	_set_icon()
	
	MainMenuButton = get_node("MainMenu")
	PlayAgainButton = get_node("PlayAgain")
	
	PlayAgainButton.connect("pressed", self, "_play_again")
	PlayAgainButton.set_enabled_focus_mode(FOCUS_NONE)

	MainMenuButton.connect("pressed", self, "_main_menu")
	MainMenuButton.set_enabled_focus_mode(FOCUS_NONE)
	
	set_process_input(true)

func _set_icon():
	if GameInfo.match_winner:
		var icon = load(PLAYER_WIN_ICONS[GameInfo.match_winner])
		PlayerDisplayNode.texture = icon

func _input(event):
	if Input.is_joy_button_pressed(event.device, JOY_START) || Input.is_key_pressed(KEY_ENTER):
		if debug_mode:
			print("controller START trying to start...")
		_play_again()

	if Input.is_joy_button_pressed(event.device, JOY_XBOX_B) || Input.is_key_pressed(KEY_BACKSPACE):
		_main_menu()

func _play_again():
	get_tree().change_scene(GameInfo.SCENE_PATHS.arena1)

func _main_menu():
	get_tree().change_scene(GameInfo.SCENE_PATHS.main_menu)
