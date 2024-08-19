class_name Base extends Area2D

@export var health: int = 100 :
	set(p_health):
		health = p_health
		health_changed.emit(health)

signal health_changed(p_health: int)

func _ready() -> void:
	body_entered.connect(enemy_entered)

func enemy_entered(body: Node2D):
	if body is Enemy:
		var enemy = body as Enemy
		health -= enemy.health
		if health <= 0:
			game_over()
	body.queue_free()

func game_over():
	print("YOU LOSE")
