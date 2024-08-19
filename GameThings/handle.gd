extends Control

var resizing = false
var scaleType = 1

var oldScale

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:			
			tower.NextTargetMode()
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
	#check towers
	var towers = get_tree().get_nodes_in_group("Tower") as Array[Tower]
	for t in towers:
		if t != tower: #not self
			if t.handle.get_global_rect().intersects(get_global_rect()):
				return true
				
	#check path
	var map = get_tree().get_first_node_in_group("Tilemap") as TileMapLayer
	var coords = map.get_used_cells()
	for coord in coords:
		if map.get_cell_tile_data(coord).get_collision_polygons_count(0)>0:
			var cellCoord = map.to_global(map.map_to_local(coord))
			if get_global_rect().intersects(Rect2(cellCoord.x-32,cellCoord.y-32,64,64)):
				return true
			for point in map.get_cell_tile_data(coord).get_collision_polygon_points(0,0):
				if get_global_rect().has_point(map.to_global(map.map_to_local(coord)+point)):
					return true			
	return false
	
@export var tower: Tower
@export var HandleSprite: NinePatchRect

@export var handleTex: Texture
@export var handleTexBad: Texture

@export var rangeHitboxes: Array[CollisionShape2D]

@onready var rangeOutline: Control = %RadiusOutline
@onready var baseSprite: Control = %BaseSprite

func _process(delta: float) -> void:
	if resizing:
		if (scaleType % 3 == 0):
			scale.x = max(abs(get_global_mouse_position() - get_global_rect().get_center()).x / size.x*2,0.5)
		if (scaleType % 5 == 0):
			scale.y = max(abs(get_global_mouse_position() - get_global_rect().get_center()).y / size.y*2,0.5)
		ResourceBar.previewBar.value = GameManager.buildResource - (GetCost() - tower.currentCost)
		if GetOverlapping() or GameManager.buildResource < GetCost() - tower.currentCost:
			HandleSprite.texture = handleTexBad
		else:
			HandleSprite.texture = handleTex
		
	else:
		HandleSprite.texture = handleTex
			
	if has_focus() or resizing:
		HandleSprite.show()
	else:
		HandleSprite.hide()
		
	if has_focus() or resizing or get_global_rect().has_point(get_global_mouse_position()):
		TowerInfo.I.Populate(tower.tower_data.type, tower.damage, tower.target_range, tower.cooldown, tower.targeting_mode)
		rangeOutline.show()
	else: 
		rangeOutline.hide()
		
	baseSprite.size = size*scale
	baseSprite.position = position + (size/2) - (baseSprite.size/2)
	
	HandleSprite.global_position = global_position
	HandleSprite.size = size * scale	
	
	rangeOutline.size = scale * size + Vector2(towerRange,towerRange) * 2
	rangeOutline.position = position + (size/2) - (rangeOutline.size/2)
	
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
