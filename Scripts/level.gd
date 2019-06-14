extends Node

func _ready():
	set_process_input(true)

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		var error = get_tree().change_scene(GameInfo.SCENE_PATHS.main_menu)
		if error != 0:
			printerr("could not change scene")
