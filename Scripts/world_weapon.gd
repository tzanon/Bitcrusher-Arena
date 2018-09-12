extends Area2D
# class for a in-world weapon to be picked up by players

export(PackedScene) var PlayerWeapon

func _ready():
	self.add_to_group("WeaponPickup")

func get_player_scene():
	return PlayerWeapon
