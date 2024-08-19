extends Node2D

class_name Tower

@onready var polygon: Polygon2D = %Polygon2D
@onready var shot_timer: Timer = %ShotTimer
@onready var firing_point: Node2D = %FiringPoint
@onready var splash_sprite: CompressedTexture2D = preload("res://Assets/Sprites/whitecircle.png")
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

func NextTargetMode():
	targeting_mode = (targeting_mode + 1) % TargetingMode.size()

@onready var sprite: Node2D = find_child("Polygon2D")
@onready var handle: Control = find_child("Handle")

var currentCost = 0
var buffer_shot: bool = false

var setup: bool = false

var target_range
var damage
var cooldown
var rate_of_fire
var splash_range
var ammo_capacity

func updateStats():

	#set base
	tower_data.type
	target_range = tower_data.target_range
	damage = tower_data.damage
	cooldown = tower_data.cooldown
	rate_of_fire = tower_data.rate_of_fire
	splash_range = tower_data.splash_range
	ammo_capacity = tower_data.ammo_capacity

	#modify
	match tower_data.type:
		TowerData.TowerType.Standard:
			damage *= currentCost/4
		TowerData.TowerType.Splash:
			splash_range *= currentCost/16
		TowerData.TowerType.Capacity:
			ammo_capacity += currentCost/4
		TowerData.TowerType.Embiggen:
			damage *= currentCost/4
		TowerData.TowerType.Ensmallen:
			damage *= currentCost/4

func Setup():
	setup = true
	recolor()
	currentCost = handle.GetCost()
	change_target_collider_radius(tower_data.target_range)
	shot_timer.timeout.connect(shoot)
	shot_timer.start()

func _process(delta: float) -> void:
	if !setup: Setup()

	updateStats()
	GetEnemiesInRange()
	retarget()
	queue_redraw()
	if target != null:
		sprite.look_at(target.position)
		#shooting mechanics and rules
		if shooting_volley:
			#shoot the next bullet in the volley when the timer goes off
			volley_timer -= delta
			if volley_timer <=0:
				reshoot.emit()
				volley_timer = rate_of_fire
				#print("volley!")
		if buffer_shot && !shooting_volley:
			shoot()
			buffer_shot = false

func _draw() -> void:
	if target != null:
		draw_line(to_local(firing_point.global_position),to_local(target.position), polygon.color, 2)

func recolor():
	match targeting_mode:
		TargetingMode.FIRST:
			polygon.color = Color.SLATE_BLUE
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
	if handle.resizing: return
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
	return new if new.distance_to_base() < old.distance_to_base() else old

func last(new: Enemy, old: Enemy):
	return new if new.distance_to_base() > old.distance_to_base() else old

func close(new: Enemy, old: Enemy):
	return new if position.distance_to(new.position) < position.distance_to(old.position) else old

func strong(new: Enemy, old: Enemy):
	return new


func change_target_collider_radius(value: float):
	handle.towerRange = value

#timer calls this on timeout or _process calls this if a shot is buffered
func shoot(override_standard:bool = false):
	#so we can re-use the standard shoot capability in other contexts/tower types
	var typeToUse: TowerData.TowerType
	if  override_standard:
		typeToUse = TowerData.TowerType.Standard
	else:
		typeToUse = tower_data.type
	if target != null:
		var directionToEnemy = (target.position - position).normalized()
		match typeToUse:
			TowerData.TowerType.Standard:
				target.take_damage(damage, directionToEnemy)
			TowerData.TowerType.Embiggen:
				target.embiggen(damage)
			TowerData.TowerType.Ensmallen:
				target.ensmallen(damage)
			TowerData.TowerType.Capacity:
				#continuously shoot (changing targets as enemies die) until ammo reaches 0
				shooting_volley = true
				damage_volley()
			TowerData.TowerType.Splash:
				#radius around target is affected
				print("sploosh")
				for enemy in get_tree().get_nodes_in_group("Enemy"):
					if enemy.global_position.distance_to(target.global_position) < splash_range:
						print(enemy.name + " is about to get splooshed")
						print(global_position.distance_to(target.global_position))
						if enemy == target:
							enemy.take_damage(damage, directionToEnemy)
						else:
							enemy.take_damage(damage, enemy.position-target.position)
				splash_visibility(target.global_position)

			_:
				print("how did we have NO TowerType?")
		if !override_standard:
			shot_timer.start(cooldown)
	else:
		shot_timer.stop() #idk if i need this but ohwell
		buffer_shot = true #

func splash_visibility(position: Vector2):
	var sprite = Sprite2D.new()
	add_child(sprite)
	sprite.global_position = position
	sprite.texture = splash_sprite
	sprite.modulate = Color(0,1,0,.2)
	sprite.scale *= splash_range/50
	var splash_timer:= get_tree().create_timer(.5)
	await splash_timer.timeout
	Callable(sprite.queue_free).call_deferred()

func damage_volley():
	#acknowledging that we COULD round it to an int but we choose not to because SCALING
	var ammo: float = ammo_capacity
	while ammo > 0:
		shoot(true)
		ammo -=1
		await reshoot
	shooting_volley = false
	shot_timer.start(cooldown)
