class_name UnitData extends Resource

enum UnitType{Normal, Fast, Slow, Armoured, Hardening, Pinata}
@export var unitType: UnitType
@export var color: Color
@export var startSize: float
@export var startHealth: float
@export var startSpeed: float
@export var sprite: Texture2D
