class_name UnitData extends Resource

enum UnitType{Normal, Fast, Slow, Armoured, Hardening, Pinata, Candy}
@export var unitType: UnitType
@export var color: Color
@export var scaleMultiplier: float = 1
@export var startHealth: float
@export var startSpeed: float
@export var sprite: Texture2D
