extends Control

var resizing = false
var scaleType = 1

var oldScale

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:			
			
			#detect edge click
			var l = event.position.x * scale.x < 16
			var r = event.position.x * scale.x > scale.x * size.x -16
			var u = event.position.y * scale.y < 16
			var d = event.position.y * scale.y > scale.y * size.y -16
			
			if l or r or u or d:
				# cursed prime numbers as identifiers
				scaleType = 1				
				scaleType *= 3 if l or r else 1
				scaleType *= 5 if u or d else 1
				
				resizing=true
			
			oldScale = scale
			
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if !GetOverlapping() and GameManager.buildResource > GetCost() - tower.currentCost:
				GameManager.buildResource -= GetCost() - tower.currentCost
				tower.currentCost = GetCost()
			else:
				scale = oldScale
			resizing = false

func GetCost():
	return get_rect().get_area() * GameManager.areaToBuildResourceRatio

func GetOverlapping():
	var towers = get_tree().get_nodes_in_group("Tower") as Array[Tower]
	for t in towers:
		if t != tower: #not self
			if t.handle.get_global_rect().intersects(get_global_rect()):
				return true
	return false
	
@export var tower: Tower
@export var HandleSprite: NinePatchRect

@export var handleTex: Texture
@export var handleTexBad: Texture

@export var rangeHitboxes: Array[CollisionShape2D]

func _process(delta: float) -> void:
	if resizing:
		if (scaleType % 3 == 0):
			scale.x = max(abs(get_global_mouse_position() - get_global_rect().get_center()).x / size.x*2,1)
		if (scaleType % 5 == 0):
			scale.y = max(abs(get_global_mouse_position() - get_global_rect().get_center()).y / size.y*2,1)
		ResourceBar.previewBar.value = GameManager.buildResource - (GetCost() - tower.currentCost)
		if GetOverlapping() or GameManager.buildResource < GetCost() - tower.currentCost:
			HandleSprite.texture = handleTexBad
		else:
			HandleSprite.texture = handleTex
		
	else:
		HandleSprite.texture = handleTex
		
	HandleSprite.global_position = global_position
	HandleSprite.size = size * scale
	
	
	
	rangeHitboxes[0].shape.height = scale.y * size.y + towerRange*2
	rangeHitboxes[0].shape.radius = towerRange
	rangeHitboxes[0].position.x = size.x/2 -(scale.x * size.x/2)
	
	rangeHitboxes[1].shape.height = scale.y * size.y + towerRange*2
	rangeHitboxes[1].shape.radius = towerRange
	rangeHitboxes[1].position.x = (scale.x * size.x/2) - size.x/2 
	
	rangeHitboxes[2].shape.height = scale.x * size.x + towerRange*2
	rangeHitboxes[2].shape.radius = towerRange
	rangeHitboxes[2].position.y = (scale.y * size.y/2) - size.y/2 
	
	rangeHitboxes[3].shape.height = scale.x * size.x + towerRange*2
	rangeHitboxes[3].shape.radius = towerRange	
	rangeHitboxes[3].position.y = size.y/2 -(scale.y * size.y/2)
	
	rangeHitboxes[4].scale = scale

@export var towerRange = 124
