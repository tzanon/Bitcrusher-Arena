# Code Conventions

Classes and Nodes: PascalCase
var MyNode = preload("path1")
const MySecondNode = preload("path2")

Enums: PascalCase for names, CONST_CASE for vars
enum Directions { NORTH, SOUTH, EAST, WEST }

Functions and Variables: snake_case
func get_node()

Leading underscore for virtual methods, private functions/vars
var _health
func _deal_damage()

Signals: snake_case with past tense name
signal door_opened
signal door_changed

Constants: CONSTANT_CASE
const MAX_SPEED = 200


