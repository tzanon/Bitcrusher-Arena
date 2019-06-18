extends Sprite

export var debug_mode = false

func _ready():
	var expl_conn_err = get_node("AnimationPlayer").connect("animation_finished", self, "_despawn")
	if expl_conn_err:
		printerr("could not connect explosion end to despawn")


func _despawn(name):
	if debug_mode:
		print("deleting player explosion after finished anim ", name)
	self.queue_free()
