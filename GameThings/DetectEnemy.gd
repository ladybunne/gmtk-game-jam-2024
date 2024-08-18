extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	body_entered.connect(enemy_entered)
	body_exited.connect(enemy_exited)

var enemies: Array[Enemy]

func enemy_entered(body: Node2D):
	var enemy := body as Enemy
	if not enemy:
		return
	
	if enemy not in enemies:
		enemies.append(enemy)

func enemy_exited(body: Node2D):
	var enemy := body as Enemy
	if not enemy:
		return
	
	if enemy in enemies:
		enemies.erase(enemy)
