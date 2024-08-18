class_name Enemy extends CharacterBody2D

@export var speed: float = 100

var spawner: Spawner

# I guess this is the better way of doing this?
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	call_deferred("actor_setup")

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

func distance_from_spawner():
	return position.distance_to(spawner.position)
