extends CanvasLayer

var base: Base = null

func _process(delta: float) -> void:
	# It's jank, who cares.
	if base == null:
		var new_base := get_tree().get_first_node_in_group("Base")
		if new_base is Base:
			base = new_base
			base.health_changed.connect(base_health_changed)	

func base_health_changed(p_health: int):
	%HealthLabel.text = str(p_health)
