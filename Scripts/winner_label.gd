extends Label

func _ready():
	set_text('Winner: ' + GameInfo.match_winner)
	pass
