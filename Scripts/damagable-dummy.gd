extends StaticBody2D

export var is_damagable = false

var Animator

export (int) var health

func _ready():
	Animator = $AnimationPlayer

func damage(dmg):
	Animator.play("dummy-dmg")
	
