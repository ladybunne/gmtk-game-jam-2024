class_name Enemy extends CharacterBody2D

var data: UnitData
@export var speed: float = 100
@export var health: float = 100
@export var type: UnitData.UnitType
@onready var visuals: EnemyPolygon = %EnemyVisuals
@onready var maxHealth: float = health

@onready var bigness: float = health
@onready var startBigness: float = health


var spawner: Spawner
@onready var hitParticles: PackedScene = preload("res://Assets/Particles/hit_particles.tscn")
# I guess this is the better way of doing this? edit: Dan made this even better with UNIQUE NAME!
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D

func _ready() -> void:
	setup()
	%ProgressBar.max_value = health
	%ProgressBar.hide()
	call_deferred("actor_setup")

#this needs to happen before _ready
func initialise(myData: UnitData):
	data = myData

func setup():
	speed = data.startSpeed
	health = data.startHealth
	bigness = health
	maxHealth = health
	startBigness = health
	visuals.radius = data.startSize
	type = data.unitType
	visuals.color = data.color


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
	health -= damage
	#print(name + str(health))
	show_damage(damage, direction)
	checkDead()
	%ProgressBar.show()
	update_healthbar()

func checkDead():
	if health <=0:
		GameManager.GainResourceFromEnemy(maxHealth)
		Callable(queue_free).call_deferred()

func embiggen(damage: float):
	health += damage
	maxHealth += damage
	%ProgressBar.max_value += damage
	bigness += damage
	%ProgressBar.show()
	updateScale()
	update_healthbar()

func ensmallen(damage: float):
	maxHealth -= damage
	%ProgressBar.max_value -= damage
	bigness -= damage
	checkDead()
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
