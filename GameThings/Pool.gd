extends Node2D

var timer = 0
var radius = 75
var grow: bool = false
var lifetime: float = 10

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime<+0:
		queue_free()

	timer -= delta
	if timer<=0:
		timer = 0.1
		for e in get_tree().get_nodes_in_group("Enemy"):
			if e is Enemy and global_position.distance_to(e.global_position) < radius:
				if grow:
					e.embiggen(2)
				else:
					e.ensmallen(2)
