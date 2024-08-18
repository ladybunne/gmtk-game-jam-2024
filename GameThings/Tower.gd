extends Node2D

class_name Tower

@export_group("Internal")
@export var polygon: Polygon2D
@export var shot_timer: Timer
@export var firing_point: Node2D
@export_group("")

enum TargetingMode {
	FIRST,
	LAST,
	CLOSE,
	STRONG,
}

@export var enemies_in_range: Array[Enemy]
@export var target: Enemy
@export var targeting_mode: TargetingMode = TargetingMode.FIRST :
	set(p_targeting_mode):
		targeting_mode = p_targeting_mode
		if polygon != null:
			recolor()
			

@onready var sprite: Node2D = find_child("Polygon2D")
@onready var handle: Control = find_child("Handle")
var currentCost = 0

func _ready() -> void:
	recolor()
	currentCost = handle.GetCost()


func _process(delta: float) -> void:
	GetEnemiesInRange()
	retarget()
	if target != null:
		sprite.look_at(target.position)
		queue_redraw()

	
func _draw() -> void:
	if target != null:
		draw_line(to_local(firing_point.global_position),to_local(target.position), polygon.color, 2)

func recolor():
	match targeting_mode:
		TargetingMode.FIRST:
			polygon.color = Color.LIGHT_BLUE
		TargetingMode.LAST:
			polygon.color = Color.LIGHT_CORAL
		TargetingMode.CLOSE:
			polygon.color = Color.LIGHT_GREEN
		TargetingMode.STRONG:
			polygon.color = Color.KHAKI

@export var rangeHitboxes: Array[Area2D]

func GetEnemiesInRange():
	enemies_in_range.clear()
	for hitbox in rangeHitboxes:
		for enemy in hitbox.enemies:
			if !enemies_in_range.has(enemy):
				enemies_in_range.append(enemy)

func retarget():
	target = null
	for enemy in enemies_in_range:
		if target == null:
			target = enemy
		else:
			match targeting_mode:
				TargetingMode.FIRST:
					target = first(enemy, target)
				TargetingMode.LAST:
					target = last(enemy, target)
				TargetingMode.CLOSE:
					target = close(enemy, target)
				TargetingMode.STRONG:
					target = strong(enemy, target)

# This needs to not do "as the crow flies" - maybe do lifetime of entity?
func first(new: Enemy, old: Enemy):
	return new if new.distance_from_spawner() > old.distance_from_spawner() else old

func last(new: Enemy, old: Enemy):
	return new if new.distance_from_spawner() < old.distance_from_spawner() else old

func close(new: Enemy, old: Enemy):
	return new if position.distance_to(new.position) < position.distance_to(old.position) else old

func strong(new: Enemy, old: Enemy):
	return new
