class_name Enemy extends CharacterBody2D

@export var speed: float = 100

var spawner: Spawner

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_collide(Vector2.RIGHT * speed * delta)

func distance_from_spawner():
	return position.distance_to(spawner.position)
