extends Node

var buildResource = 100
var areaToBuildResourceRatio = 1.0/1024.0

static var INITIAL_COST = 4

var funding = 10 :
	set(p_funding):
		funding = p_funding
		funding_changed.emit(funding)

signal funding_changed(funding: int)

@export var tower: PackedScene = preload("res://GameThings/Tower.tscn")

var placing: bool = false
var towerData: TowerData

var selling: bool = false

func PlacingTower(data: TowerData):
	placing = true
	towerData = data

var cursor: Node2D

func _process(delta: float) -> void:	
	if cursor == null:
		cursor = get_tree().get_first_node_in_group("Cursor")
	else:
		if placing:
			ResourceBar.previewBar.value = buildResource - INITIAL_COST
			cursor.show()
		else:
			cursor.hide()
		cursor.global_position = cursor.get_global_mouse_position()
	
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if placing:
				placing = false
				ResourceBar.previewBar.value = buildResource
			if selling:
				selling = false
				
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if placing:
				if buildResource >= INITIAL_COST:
					var t = tower.instantiate() as Tower
					get_tree().get_first_node_in_group("Level").add_child(t)
					t.position = t.get_global_mouse_position()
					t.tower_data = towerData
					
					#cancel placement if overlapping track or towers
					if t.handle.GetOverlapping():
						t.queue_free()
						ResourceBar.previewBar.value = buildResource
						placing = false
						return
					
					buildResource -= INITIAL_COST
					ResourceBar.previewBar.value = buildResource
					
				placing = false
				
			elif selling:
				for t: Tower in get_tree().get_nodes_in_group("Tower"):
					if t.handle.get_global_rect().has_point(t.get_global_mouse_position()):
						t.queue_free()
						buildResource += t.handle.GetCost()
						ResourceBar.previewBar.value = buildResource						
				selling = false
