extends Area2D

func _ready() -> void:
	body_entered.connect(enemy_entered)

func enemy_entered(body: Node2D):
	body.queue_free()
