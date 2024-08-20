class_name Spawner extends Node2D

@onready var next_unit_spawn_timer: Timer = %NextSpawnTimer
@onready var next_corps_spawn_timer: Timer = %NextCorpsTimer
@onready var next_wave_timer: Timer = %NextWaveTimer
@onready var enemyScene: PackedScene = preload("res://GameThings/Enemy.tscn")
@export var waveSet: WaveSetData
@export var debugWaveset: WaveSetData
var currentWaveIndex: int = 0
var currentCorpsIndex: int = 0
var currentUnitIndex: int = 0
@export_group("Debug")
@export var debugEnemies: bool = false

signal all_done

var currentWave:
	get:
		return waveSet.waves[currentWaveIndex]
var currentCorps:
	get:
		return waveSet.waves[currentWaveIndex].corps[currentCorpsIndex]
var currentUnit:
	get:
		return waveSet.waves[currentWaveIndex].corps[currentCorpsIndex].units[currentUnitIndex]

func _ready():
	if debugEnemies:
		waveSet = debugWaveset
	spawn_wave(currentWave)


func _process(_delta: float):
	get_tree().get_first_node_in_group("WaveText").text = "Wave: " \
	+str(currentWaveIndex+1)+"/"+str(waveSet.waves.size())

func spawn_units():
	while currentUnitIndex < currentCorps.units.size():
		create_enemy(currentUnit)
		next_unit_spawn_timer.wait_time = currentCorps.unitInterval
		next_unit_spawn_timer.start()
		await next_unit_spawn_timer.timeout
		currentUnitIndex+=1
	currentUnitIndex = 0

func create_enemy(data: UnitData):
		var new_enemy: Enemy = enemyScene.instantiate() as Enemy
		new_enemy.initialise(data)
		new_enemy.position = position
		get_parent().add_child(new_enemy)


func spawn_all_corps(corps: CorpsData):
	while currentCorpsIndex < currentWave.corps.size():
		print("Wave "+str(currentWaveIndex+1) + ", Corps "+str(currentCorpsIndex+1))
		await spawn_units()
		currentCorpsIndex+=1
		next_corps_spawn_timer.wait_time = currentWave.corpsInterval
		next_corps_spawn_timer.start()
		await next_corps_spawn_timer.timeout

	currentCorpsIndex = 0

func spawn_wave(wave: WaveData):
	while currentWaveIndex < waveSet.waves.size():
		await spawn_all_corps(currentCorps)
		currentWaveIndex+=1
		GameManager.availableTowers += 0.6
		next_wave_timer.wait_time = waveSet.waveInterval
		next_wave_timer.start()
		await next_wave_timer.timeout


	currentWaveIndex-=1
	print("out of waves")
	all_done.emit()

#DEPRECATED
#@export var enemy_to_spawn: PackedScene
#var enemiesInWave = 20
#@export var spawnableEnemies: Array[PackedScene]
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#next_spawn_timer.timeout.connect(spawn_enemy)
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if get_tree().get_nodes_in_group("Enemy").size() == 0 and enemiesInWave <= 0:
		#print("WIN")
#
#func spawn_enemy():
	#if enemiesInWave>0:
		#enemiesInWave-=1
		#var new_enemy: Enemy = spawnableEnemies.pick_random().instantiate() as Enemy
		#new_enemy.position = position
		#new_enemy.spawner = self
		#get_parent().add_child(new_enemy)
