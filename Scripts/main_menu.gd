extends Node

func _ready():
	var start_button = get_node("/root/MainMenu/Control/StartButton")
	start_button.connect("pressed", self, "_play_game")
	
	set_process_input(true)

func _input(event):
	if Input.is_joy_button_pressed(event.device, JOY_START) || Input.is_key_pressed(KEY_ENTER):
		_play_game()

func _play_game():
	get_tree().change_scene(GameInfo.SCENE_PATHS.player_select)
