extends Area2D

class_name Tower

@onready var polygon: Polygon2D = %Polygon2D
@onready var shot_timer: Timer = %ShotTimer
@onready var firing_point: Node2D = %FiringPoint
@onready var collider: CollisionShape2D = %CollisionShape2D
@export_group("")

@export var tower_data: TowerData

enum TargetingMode {
	FIRST,
	LAST,
	CLOSE,
	STRONG,
}

#currently used to tell Damage_Volley when to shoot again
signal reshoot
var shooting_volley: bool = false
var volley_timer: float
@export var enemies_in_range: Array[Enemy]
@export var target: Enemy
@export var targeting_mode: TargetingMode = TargetingMode.FIRST :
	set(p_targeting_mode):
		targeting_mode = p_targeting_mode
		if polygon != null:
			recolor()


@onready var sprite: Node2D = find_child("Polygon2D")
@onready var handle: Control = find_child("Handle")
var currentCost
var buffer_shot: bool = false
func _ready() -> void:
	body_entered.connect(enemy_entered)
	body_exited.connect(enemy_exited)
	recolor()
	currentCost = handle.GetCost()
	change_target_collider_radius(tower_data.target_range)
	shot_timer.timeout.connect(shoot)



func _process(delta: float) -> void:
	if target != null:
		sprite.look_at(target.position)
		queue_redraw()
		#shooting mechanics and rules
		if shooting_volley:
			#shoot the next bullet in the volley when the timer goes off
			volley_timer -= delta
			if volley_timer <=0:
				reshoot.emit()
				volley_timer = tower_data.rate_of_fire
		if buffer_shot && !shooting_volley:
			shoot()
			buffer_shot = false
	retarget()




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

func enemy_exited(body: Node2D):
	var enemy := body as Enemy
	if not enemy:
		return

	if enemy in enemies_in_range:
		enemies_in_range.erase(enemy)

# This needs to not do "as the crow flies" - maybe do lifetime of entity?
func first(new: Enemy, old: Enemy):
	return new if new.distance_to_base() < old.distance_to_base() else old

func last(new: Enemy, old: Enemy):
	return new if new.distance_to_base() > old.distance_to_base() else old

func close(new: Enemy, old: Enemy):
	return new if position.distance_to(new.position) < position.distance_to(old.position) else old

func strong(new: Enemy, old: Enemy):
	return new


func change_target_collider_radius(value: float):
	collider.radius = value

#timer calls this on timeout or _process calls this if a shot is buffered
func shoot(override_standard:bool = false):
	#so we can re-use the standard shoot capability in other contexts/tower types
	var typeToUse: TowerData.TowerType
	if  override_standard:
		typeToUse = TowerData.TowerType.Standard
	else:
		typeToUse = tower_data.type

	if target != null:
		match tower_data.type:
			TowerData.TowerType.Standard:
				target.take_damage(tower_data.damage)
				pass
			TowerData.TowerType.Capacity:
				#continuously shoot (changing targets as enemies die) until ammo reaches 0
				shooting_volley = true
				pass
			TowerData.TowerType.Splash:
				#radius around target is affected
				pass
		if !override_standard:
			shot_timer.start(tower_data.cooldown)
	else:
		shot_timer.stop() #idk if i need this but ohwell
		buffer_shot = true #

func damage_volley():
	#acknowledging that we COULD round it to an int but we choose not to because SCALING
	var ammo: float = tower_data.ammo_capacity
	while ammo > 0:
		shoot(true)
		ammo -=1
		await reshoot
	shooting_volley = false
	shot_timer.start(tower_data.cooldown)
