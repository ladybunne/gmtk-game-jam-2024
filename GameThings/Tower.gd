extends Area2D

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
			

func _ready() -> void:
	body_entered.connect(enemy_entered)
	body_exited.connect(enemy_exited)
	recolor()

func _process(delta: float) -> void:
	if target != null:
		rotation = rotation + get_angle_to(target.position) + 0.5 * PI
		queue_redraw()

	
func _draw() -> void:
	if target != null:
		draw_line(firing_point.position, target.position, polygon.color, 2)

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

func enemy_entered(body: Node2D):
	var enemy := body as Enemy
	if not enemy:
		return
	
	if enemy not in enemies_in_range:
		enemies_in_range.append(enemy)
	
	retarget()

func enemy_exited(body: Node2D):
	var enemy := body as Enemy
	if not enemy:
		return
	
	if enemy in enemies_in_range:
		enemies_in_range.erase(enemy)
	
	retarget()

# This needs to not do "as the crow flies" - maybe do lifetime of entity?
func first(new: Enemy, old: Enemy):
	return new if new.distance_from_spawner() > old.distance_from_spawner() else old

func last(new: Enemy, old: Enemy):
	return new if new.distance_from_spawner() < old.distance_from_spawner() else old

func close(new: Enemy, old: Enemy):
	return new if position.distance_to(new.position) < position.distance_to(old.position) else old

func strong(new: Enemy, old: Enemy):
	return new
