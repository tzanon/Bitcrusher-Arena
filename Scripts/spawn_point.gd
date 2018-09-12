extends Sprite

export(PackedScene) var WorldObject setget ,get_object_scene
export var PossibleObjects = [] setget ,get_possible_scenes

func get_object_scene():
	return WorldObject

func get_possible_scenes():
	return PossibleObjects
