extends TextureRect

const default_icon = preload("res://Sprites/UI/player_default_icon.png")
const dead_icon = preload("res://Sprites/UI/player_dead_icon.png")

var icon
var health_bar

const max_health = 100

func _ready():
	icon = get_node("Icon")
	if icon == null:
		print("no icon node found")
	health_bar = get_node("HealthBar")

func update_health(new_health):
	var health = clamp(new_health, 0.0, 100.0)
	
	var bar_scale = Vector2(health / max_health, health_bar.get_scale().y)
	health_bar.set_scale(bar_scale)

func set_death_icon():
	set_icon(dead_icon)

func set_icon_with_path(icon_path):
	icon.texture = load(icon_path)

func set_icon(icon_texture):
	icon.texture = icon_texture
