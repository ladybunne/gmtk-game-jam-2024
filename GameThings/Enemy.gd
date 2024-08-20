class_name Enemy extends CharacterBody2D

var data: UnitData
var baseSpeed: float = 100
@export var speed: float = 100
@export var health: float = 100
@export var type: UnitData.UnitType
@onready var visuals: EnemyPolygon = %EnemyVisuals
@onready var maxHealth: float = health
@onready var candyUnit: UnitData = preload("res://GameThings/WaveResources/EnemyResources/CandySubUnit.tres")
@onready var enemyScene: PackedScene = preload("res://GameThings/Enemy.tscn")
@onready var bigness: float = health
@onready var startBigness: float = health
var isDebuffed: bool = false
var hits_taken: int = 0
@onready var mouth: Polygon2D = %Mouth
@onready var sprite: Sprite2D = %Sprite2D
#var spawner: Spawner
@onready var hitParticles: PackedScene = preload("res://Assets/Particles/hit_particles.tscn")
# I guess this is the better way of doing this? edit: Dan made this even better with UNIQUE NAME!
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var debuffParticles: CPUParticles2D = %DebuffParticles
func _ready() -> void:
	setup()
	%ProgressBar.max_value = health
	%ProgressBar.hide()
	call_deferred("actor_setup")

#this needs to happen before _ready
func initialise(myData: UnitData):
	data = myData

func setup():
	baseSpeed = data.startSpeed
	speed = baseSpeed
	health = data.startHealth
	bigness = health
	maxHealth = health
	startBigness = health
	type = data.unitType
	visuals.color = data.color
	sprite.texture = data.sprite
	sprite.scale *= data.scaleMultiplier



func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	var base = get_tree().get_first_node_in_group("Base")
	set_movement_target(base.position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * speed
	move_and_slide()

func distance_to_base():
	# Ughhhhh.
	# Thanks GitHub.
	#
	# This is from https://github.com/godotengine/godot-proposals/issues/8296
	# Sourced by Larrikin.

	var arr = navigation_agent.get_current_navigation_path()

	var current_index := 0
	var result = 0
	var current_pos = arr[navigation_agent.get_current_navigation_path_index()]
	for i in arr:
		if current_index <= navigation_agent.get_current_navigation_path_index():
			current_index += 1
			continue
		result += current_pos.distance_to(i)
		current_pos = i
	return result

func take_damage(damage: float, direction: Vector2):
	if data.unitType==data.UnitType.Hardening:
		damage *= lerp(1.0,0.5,hits_taken/100.0)
	elif data.unitType==data.UnitType.Armoured:
		damage += hits_taken
		damage -= 20
		if damage <0:
			damage = 0.5
	hits_taken+=1
	health -= damage
	#print(name + str(health))
	show_damage(damage, direction)
	checkDead()
	%ProgressBar.show()
	update_healthbar()
	if data.unitType==data.UnitType.Hardening:
		sprite.material.set_shader_parameter("tint",Vector3(1,1 - hits_taken/100.0,1 - hits_taken/100.0))


func debuff(damage: float):
	update_speed(damage/100.0, false, true)
	isDebuffed = true
	debuffParticles.emitting = true
	debuffParticles.emission_sphere_radius *= data.scaleMultiplier
	sprite.material.set_shader_parameter("slowTint",Vector3(0.8,1,0.8))


func checkDead():
	if health <=0:
		if data.unitType == UnitData.UnitType.Pinata:
			var i = 20*bigness/100
			var randnum = 50
			while i > 0:
				var new_enemy: Enemy = enemyScene.instantiate() as Enemy
				new_enemy.initialise(candyUnit)
				var r = randi_range(0,candyUnit.spriteOptions.size()-1)
				candyUnit.sprite = candyUnit.spriteOptions[r]
				var offset: Vector2 = Vector2(randf_range(-randnum,randnum),randf_range(-randnum,randnum))
				new_enemy.position = position+offset
				get_parent().add_child(new_enemy)
				i-=1
		GameManager.GainResourceFromEnemy(maxHealth)
		Callable(queue_free).call_deferred()

func embiggen(damage: float):
	health += damage
	maxHealth += damage
	%ProgressBar.max_value += damage
	bigness += damage
	update_speed(damage, false)
	%ProgressBar.show()
	updateScale()
	update_healthbar()

func update_speed(modifier: float, faster: bool, isMultiplier: bool = false):
	if faster:
		if isMultiplier:
			speed /= modifier
		else:
			speed += modifier
	else:
		if isMultiplier:
			speed *= modifier
		else:
			speed -= modifier
	if speed < baseSpeed/2:
		speed = baseSpeed/2

func ensmallen(damage: float):
	maxHealth -= damage
	%ProgressBar.max_value -= damage
	bigness -= damage
	checkDead()
	update_speed(damage, true)
	%ProgressBar.show()
	updateScale()
	update_healthbar()

func updateScale():
	if bigness<=0:
		Callable(queue_free).call_deferred()
	scale = Vector2(1,1) * bigness/startBigness

func show_damage(damage: float, direction: Vector2):
		var flecks: CPUParticles2D = hitParticles.instantiate()
		get_tree().get_first_node_in_group("Level").add_child(flecks)
		flecks.global_position = global_position
		flecks.direction = direction
		flecks.scale_amount_max = damage/log(10)
		flecks.emitting = true
		flecks.finished.connect(func(): kill_particle(flecks))

func kill_particle(particle: CPUParticles2D):
	Callable(particle.queue_free).call_deferred()

func update_healthbar():
	%ProgressBar.value = health
