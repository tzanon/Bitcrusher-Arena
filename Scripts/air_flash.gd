extends Sprite

func _ready():
	get_node("AnimationPlayer").connect("animation_finished", self, "_end_flash")

func _end_flash(name):
	_despawn()

func _despawn():
	self.queue_free()
