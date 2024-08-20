extends RichTextLabel

func _process(delta: float) -> void:
	text = str(floor(GameManager.buildResource * 100) / 100)
