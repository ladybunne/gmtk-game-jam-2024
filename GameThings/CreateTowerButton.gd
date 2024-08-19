extends TextureButton

@export var data: TowerData
@export var sell: bool

func _pressed() -> void:
	if sell:
		GameManager.selling = true
	else:
		GameManager.PlacingTower(data)

func _process(delta: float) -> void:
	if sell:
		$Label.text = "Click Target" if GameManager.selling else "Sell Tower"
