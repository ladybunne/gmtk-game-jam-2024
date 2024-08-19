extends Node

var buildResource = 15
var areaToBuildResourceRatio = 1.0/1024.0

var barMax

func GainResourceFromEnemy(value: float):
	GameManager.buildResource += value/50
	ResetBar()


func ResetBar():
	ResourceBar.mainBar.value = buildResource
	ResourceBar.previewBar.value = buildResource
	SetBarMax()
	ResourceBar.mainBar.max_value = barMax
	ResourceBar.previewBar.max_value = barMax

static var INITIAL_COST = 4

var funding = 10 :
	set(p_funding):
		funding = p_funding
		funding_changed.emit(funding)

signal funding_changed(funding: int)

@export var tower: PackedScene = preload("res://GameThings/Tower.tscn")

var availableTowers: float = 3

var placing: bool = false
var towerData: TowerData

var selling: bool = false

func PlacingTower(data: TowerData):
	if availableTowers>=1:
		placing = true
		towerData = data

var cursor: Node2D

# These are a bit dumb. Sorry. -Ladybunne
var base: Base
var end_screen_ui: EndScreenUI

@export var bigPool: PackedScene = preload("res://GameThings/Pool.tscn")
var placingPool: bool = false
var poolIsBig: bool = false
func _process(delta: float) -> void:
	get_tree().get_first_node_in_group("TowerCountText").text = "Available Towers: " + str(floor(availableTowers))
	if cursor == null:
		cursor = get_tree().get_first_node_in_group("Cursor")
	if base == null:
		base = get_tree().get_first_node_in_group("Base")
		# this is breaking lmao
		# Invalid access to property or key 'base_died' on a base object of type 'null instance'.
		if base != null:
			base.base_died.connect(func(): game_over(false))
	if end_screen_ui == null:
		end_screen_ui = get_tree().get_first_node_in_group("TerribleEndScreenGroup")
		if end_screen_ui != null:
			end_screen_ui.button.pressed.connect(restart_scene)
	else:
		if placing:
			ResourceBar.previewBar.value = buildResource - INITIAL_COST
			cursor.show()
		elif placingPool:
			cursor.show()
		else:
			cursor.hide()
		cursor.global_position = cursor.get_global_mouse_position()
	SetBarMax()

func SetBarMax():
	var total = 0
	for tower in get_tree().get_nodes_in_group("Tower") as Array[Tower]:
		total += tower.currentCost
	barMax = buildResource + total

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if placing:
				placing = false
				ResourceBar.previewBar.value = buildResource
			if selling:
				selling = false
			if placingPool:
				placingPool = false

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if placingPool:
				var p = bigPool.instantiate()
				get_tree().get_first_node_in_group("Level").add_child(p)
				p.grow = poolIsBig
				p.position = p.get_global_mouse_position()
				get_tree().get_first_node_in_group("bigButton" if poolIsBig else "smallButton").ConsumeCharge()
				placingPool = false


			if placing:
				if buildResource >= INITIAL_COST:
					var t = tower.instantiate() as Tower
					get_tree().get_first_node_in_group("Level").add_child(t)
					t.position = t.get_global_mouse_position()
					t.tower_data = towerData

					#cancel placement if overlapping track or towers
					if t.handle.GetOverlapping():
						t.queue_free()
						ResourceBar.previewBar.value = ResourceBar.mainBar.value
						placing = false
						return

					buildResource -= INITIAL_COST
					availableTowers-=1

				placing = false

			elif selling:
				for t: Tower in get_tree().get_nodes_in_group("Tower"):
					if t.handle.get_global_rect().has_point(t.get_global_mouse_position()):
						t.queue_free()
						buildResource += t.handle.GetCost()
						ResourceBar.previewBar.value = buildResource
				selling = false

func game_over(p_win: bool):
	#get_tree().paused = true
	end_screen_ui.win = p_win
	end_screen_ui.visible = true

func restart_scene():
	cursor = null
	base = null
	end_screen_ui = null
	buildResource = 100
	get_tree().reload_current_scene()
