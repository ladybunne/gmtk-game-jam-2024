extends Node

var buildResource = 30
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
	else:
		AudioManager.play_sfx("No")

var cursor: Node2D

# These are a bit dumb. Sorry. -Ladybunne
var base: Base
var spawner: Spawner
var end_screen_ui: EndScreenUI

var all_done_received: bool = false

@export var bigPool: PackedScene = preload("res://GameThings/Pool.tscn")
var placingPool: bool = false
var poolIsBig: bool = false

var game_over_on: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	var tower_count_text = get_tree().get_first_node_in_group("TowerCountText")
	if tower_count_text:
		tower_count_text.text = "Available Towers: " + str(floor(availableTowers))
	if cursor == null:
		cursor = get_tree().get_first_node_in_group("Cursor")
	if base == null:
		base = get_tree().get_first_node_in_group("Base")
		# this is breaking lmao
		# Invalid access to property or key 'base_died' on a base object of type 'null instance'.
		if base != null:
			base.base_died.connect(func(): game_over(false))
	if spawner == null:
		spawner = get_tree().get_first_node_in_group("Spawner")
		# this is breaking lmao
		# Invalid access to property or key 'base_died' on a base object of type 'null instance'.
		if spawner != null:
			spawner.all_done.connect(func(): all_done_received = true)
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

	if get_tree().get_node_count_in_group("Enemy") == 0 and all_done_received:
		all_done_received = false
		game_over(true)


func SetBarMax():
	var total = 0
	for tower in get_tree().get_nodes_in_group("Tower") as Array[Tower]:
		total += tower.currentCost
	barMax = buildResource + total

func _input(event: InputEvent) -> void:
	if game_over_on and event is InputEventMouseButton and event.pressed:
		restart_scene()

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
						AudioManager.play_sfx("No")
						return

					AudioManager.play_sfx("ting")
					buildResource -= INITIAL_COST
					availableTowers-=1

				placing = false

			elif selling:
				for t: Tower in get_tree().get_nodes_in_group("Tower"):
					if t.handle.get_global_rect().has_point(t.get_global_mouse_position()):
						t.queue_free()
						buildResource += t.handle.GetCost()
						ResourceBar.previewBar.value = buildResource
						AudioManager.play_sfx("slwp")
				selling = false

func game_over(p_win: bool):
	get_tree().paused = true
	game_over_on = true
	end_screen_ui.win = p_win
	end_screen_ui.visible = true

func restart_scene():
	availableTowers = 3
	placing = false
	placingPool = false
	selling = false
	game_over_on = false
	cursor = null
	base = null
	spawner = null
	end_screen_ui = null
	buildResource = 100
	all_done_received = false
	get_tree().paused = false
	print_rich("ignore those errors, they're [wave amp=50.0 freq=5.0 connected=1]garbage[/wave]")
	get_tree().reload_current_scene()
