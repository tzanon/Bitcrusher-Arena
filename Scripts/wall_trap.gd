extends Sprite

export var debug_mode = false;

export(PackedScene) var Projectile

onready var ProjSpawnPoint = get_node("ProjectileSpawnPoint")
var DEFAULT_PROJ_SPAWN_PATH = GameInfo.NODE_SPAWN_PATHS.projectile # "/root/Level/Projectiles"

var ProjSpawnNode

# how often the trap fires
export(float, 0.05, 10, 0.05) var _fire_rate = 3

func _ready():
	
	if has_node(DEFAULT_PROJ_SPAWN_PATH):
		ProjSpawnNode = get_node(DEFAULT_PROJ_SPAWN_PATH)
	else:
		ProjSpawnNode = get_tree().get_root()
	
	if debug_mode:
		print("spawn node is ", ProjSpawnNode)
	
	var FireTimer = Timer.new()
	self.add_child(FireTimer)
	FireTimer.wait_time = _fire_rate
	FireTimer.connect("timeout", self, "fire")
	FireTimer.start()
	

func fire():
	
	# TODO: refactor
	# timing of firing (and hence sound effects) should be handled in central controller node/class
	
	var projectile = Projectile.instance()
	projectile.global_position = ProjSpawnPoint.global_position
	projectile.global_rotation = self.global_rotation
	
	if has_node(DEFAULT_PROJ_SPAWN_PATH):
		get_node(DEFAULT_PROJ_SPAWN_PATH).add_child(projectile)
	else:
		get_tree().get_root().add_child(projectile)
	
	#ProjSpawnNode.add_child(projectile)
