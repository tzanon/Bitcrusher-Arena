extends TextureRect

const DEFAULT_ICON = preload("res://Sprites/UI/player_default_icon.png")
const DEAD_ICON = preload("res://Sprites/UI/player_dead_icon.png")

var Icon
var HealthBar

const MAX_HEALTH = 100

func _ready():
	Icon = get_node("Icon")
	if !Icon:
		print("no Icon node found")
	HealthBar = get_node("HealthBar")

func update_health(new_health):
	var health = clamp(new_health, 0.0, 100.0)
	
	var bar_scale = Vector2(health / MAX_HEALTH, HealthBar.get_scale().y)
	HealthBar.set_scale(bar_scale)

func set_death_icon():
	set_icon(DEAD_ICON)

func set_icon_with_path(icon_path):
	Icon.texture = load(icon_path)

func set_icon(icon_texture):
	Icon.texture = icon_texture
