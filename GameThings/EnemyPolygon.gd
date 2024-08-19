@tool
class_name EnemyPolygon extends Node2D

@export var color: Color = Color.YELLOW
@export var radius: float = 24

func _draw() -> void:
	draw_circle(position, radius, color, true)
