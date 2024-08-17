@tool
extends Node2D

func _draw() -> void:
	draw_circle(position, 24, Color.YELLOW, true)
