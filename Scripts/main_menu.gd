extends Node

export var select_menu_path = "res://Scenes/PlayerSelectMenu.tscn"

func _ready():
	var start_button = get_node("/root/MainMenu/Control/StartButton")
	start_button.connect("pressed", self, "_play_game")
	
	set_process_input(true)

func _input(event):
	if Input.is_joy_button_pressed(event.device, JOY_START):
		_play_game()

func _play_game():
	get_tree().change_scene(select_menu_path)
