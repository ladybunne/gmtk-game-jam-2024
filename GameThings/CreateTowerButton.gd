extends TextureButton

@export var data: TowerData
@export var sell: bool
@export var pool: bool
@export var poolIsBig: bool
var tower_limit:
	get:
		return get_tree().get_first_node_in_group("Spawner").currentWaveIndex+1
var current_tower_count:
	get:
		return get_tree().get_nodes_in_group("Tower").size()
var charges = 2
var chargeTimer = 3

func ConsumeCharge():
	charges -= 1

func _pressed() -> void:
	if sell:
		GameManager.selling = true
	elif pool:
		if charges>0:
			GameManager.placingPool = true
			GameManager.poolIsBig = poolIsBig
	else:
		if current_tower_count <= tower_limit:
			GameManager.PlacingTower(data)
		else:
			print(str(current_tower_count)+" "+ str(tower_limit))
			AudioManager.play_sfx("No")


func _process(delta: float) -> void:
	if sell:
		$Label.text = "Click Target" if GameManager.selling else "Sell Tower"
	if pool:
		if charges < 2:
			chargeTimer-= delta
			if chargeTimer<=0:
				chargeTimer = 3
				charges+=1
		if charges >=2:
			$Dot2.show()
		else:
			$Dot2.hide()
		if charges >=1:
			$Dot1.show()
		else:
			$Dot1.hide()
