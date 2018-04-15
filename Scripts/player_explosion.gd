extends Sprite

func _ready():
	get_node("AnimationPlayer").connect("animation_finished", self, "_explosion_finished")

func _explosion_finished(name):
	self._despawn()

func _despawn():
	self.queue_free()
