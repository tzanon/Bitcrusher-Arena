extends Sprite

func _ready():
	get_node("AnimationPlayer").connect("animation_finished", self, "_flash_finished")

func _flash_finished(name):
	_despawn()

func _despawn():
	self.queue_free()
