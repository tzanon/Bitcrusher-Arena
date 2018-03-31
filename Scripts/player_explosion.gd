extends Sprite

func _ready():
	get_node("AnimationPlayer").connect("finished", self, "_despawn")

func _despawn():
	self.queue_free()
