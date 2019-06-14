extends Sprite

func _ready():
	var expl_conn_err = get_node("AnimationPlayer").connect("animation_finished", self, "_despawn")
	if expl_conn_err:
		printerr("could not connect explosion end to despawn")
	
	


func _despawn():
	self.queue_free()
