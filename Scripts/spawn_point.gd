extends Sprite

export(PackedScene) var world_object_scene setget ,get_object_scene
export var possible_object_scenes = [] setget ,get_possible_scenes

func get_object_scene():
	return world_object_scene

func get_possible_scenes():
	return possible_object_scenes
