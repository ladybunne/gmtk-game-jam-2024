extends Node2D

class_name Tower

@onready var polygon: Sprite2D
@onready var shot_timer: Timer = %ShotTimer
@onready var firing_point: Node2D:
	get:
		return polygon.find_child("FiringPoint")
@onready var splash_sprite: CompressedTexture2D = preload("res://Assets/Sprites/whitecircle.png")
@export_group("")

@export var tower_data: TowerData
@onready var standard_gon: PackedScene = preload("res://Assets/Polygons/StandardGon.tscn")
@onready var capacity_gon: PackedScene = preload("res://Assets/Polygons/CapacityGon.tscn")
@onready var splash_gon: PackedScene = preload("res://Assets/Polygons/SplashGon.tscn")
@onready var sniper_gon: PackedScene = preload("res://Assets/Polygons/SniperGon.tscn")
@onready var sniper_gon2: PackedScene = preload("res://Assets/Polygons/SniperGon2.tscn")
@onready var slow_gon: PackedScene = preload("res://Assets/Polygons/SlowGon.tscn")
@onready var sprite: Node2D:
	get:
		return polygon
var isEqualizer: bool:
	get:
		return tower_data.type == TowerData.TowerType.Equalizer
var isDebuff: bool:
	get:
		return tower_data.type == TowerData.TowerType.Debuff
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
			damage *= 1 + (currentCost/10)
		TowerData.TowerType.Splash:
			splash_range *= 1 + (currentCost/12)
			damage *= 1 + (currentCost/18)
		TowerData.TowerType.Capacity:
			ammo_capacity += currentCost*1.1
			damage += currentCost/20
			cooldown += currentCost/40
		TowerData.TowerType.Embiggen:
			damage *= currentCost/4
		TowerData.TowerType.Ensmallen:
			damage *= currentCost/4
		TowerData.TowerType.Sniper:
			damage *= 1 + (currentCost/18)
			cooldown -=  1.3 * (1 - (1 / (1 +currentCost/80)))
		TowerData.TowerType.Debuff:
			damage *= 1 + (currentCost/8)

@export var standardTex :Texture
@export var splashTex :Texture
@export var burstTex :Texture
@export var sniperTex :Texture
@export var slowTex :Texture

func Setup():
	setup = true
	match tower_data.type:
		TowerData.TowerType.Standard:
			%BaseSprite.texture = standardTex
			polygon = standard_gon.instantiate()
			add_child(polygon)
			move_child(polygon,6)
		TowerData.TowerType.Capacity:
			%BaseSprite.texture = burstTex
			polygon = capacity_gon.instantiate()
			add_child(polygon)
			move_child(polygon,6)
		TowerData.TowerType.Splash:
			%BaseSprite.texture = splashTex
			polygon = splash_gon.instantiate()
			add_child(polygon)
			move_child(polygon,6)
		TowerData.TowerType.Sniper:
			%BaseSprite.texture = sniperTex
			polygon = sniper_gon.instantiate()
			add_child(polygon)

			polygon.get_child(0).add_child(sniper_gon2.instantiate())
		TowerData.TowerType.Debuff:
			%BaseSprite.texture = slowTex
			polygon = slow_gon.instantiate()
			add_child(polygon)
			move_child(polygon,6)
		_:
			pass
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
		if tower_data.type == TowerData.TowerType.Sniper:
			sprite.get_child(0).look_at(target.position)
		else:
			sprite.look_at(target.position)
			var rot = (roundi(sprite.rotation_degrees) + 720) % 360
			sprite.flip_v = rot > 90 and rot < 270
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
	return
	if target != null && !isEqualizer:
		draw_line(to_local(firing_point.global_position),to_local(target.position), polygon.color, 2)

func recolor():
	return
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
	if isEqualizer:
		return
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
	return new if new.health > old.health else old


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
				#print("sploosh")
				for enemy in get_tree().get_nodes_in_group("Enemy"):
					if enemy.global_position.distance_to(target.global_position) < splash_range:
						#print(enemy.name + " is about to get splooshed")
						#print(global_position.distance_to(target.global_position))
						if enemy == target:
							enemy.take_damage(damage, directionToEnemy)
						else:
							enemy.take_damage(damage, enemy.position-target.position)
				splash_visibility(target.global_position)
			TowerData.TowerType.Sniper:
				target.take_damage(damage, directionToEnemy)
			TowerData.TowerType.Equalizer:
				print("this shouldn't happen because equalizers don't target")
			TowerData.TowerType.Debuff:
				target.debuff(40)
				target.take_damage(damage, directionToEnemy)
			_:
				print("how did we have NO TowerType?")
		if isEqualizer:
			Equalize()
		AudioManager.play_sfx(tower_data.shot_sfx_string)
		if !override_standard:
			shot_timer.start(cooldown)
	else:
		shot_timer.stop() #idk if i need this but ohwell
		buffer_shot = true #

func Equalize():
	var totalBigness: float = 0
	var totalHealth: float = 0
	var totalSpeed: float = 0
	for enemy in enemies_in_range:
		totalBigness+- enemy.bigness
		totalHealth += enemy.health
		totalSpeed += enemy.speed
	var averageBig = totalBigness/enemies_in_range.size()
	var averageHealth = totalHealth/enemies_in_range.size()
	var averageSpeed = totalSpeed/enemies_in_range.size()

	#maybe later implement the coroutine
	#for enemy in enemies_in_range:
		#enemy.health = lerpf(enemy.health, averageHealth, tower_data.damage)
		#enemy.speed = lerpf(enemy.speed, averageSpeed, tower_data.damage)
		#enemy.bigness = lerpf(enemy.bigness, averageBig, tower_data.damage)

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
