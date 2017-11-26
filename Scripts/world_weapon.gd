extends Area2D
# class for a in-world weapon to be picked up by players

export(PackedScene) var player_weapon_scene

func _ready():
	self.add_to_group("Weapon")

