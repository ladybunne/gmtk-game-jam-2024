class_name TowerData extends Resource

enum TowerType{Standard, Capacity, Splash, Embiggen, Ensmallen}

@export_group("Stats")
@export var damage: float = 5
@export var cooldown: float = .5
@export var target_range: float = 10
@export_group("Splash Uniques")
@export var splash_range: float = 200
@export_group("Capacity Uniques")
@export var ammo_capacity: float = 10
@export var rate_of_fire: float = 0.1
@export_group("")
@export var type: TowerType = TowerType.Standard
