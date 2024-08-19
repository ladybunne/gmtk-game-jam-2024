class_name Spawner extends Node2D

@onready var next_spawn_timer: Timer = %NextSpawnTimer
@onready var next_wave_timer: Timer = %NextWaveTimer

@export var enemy_to_spawn: PackedScene

@export var spawnableEnemies: Array[PackedScene]

var enemiesInWave = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_spawn_timer.timeout.connect(spawn_enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("Enemy").size() == 0 and enemiesInWave <= 0:
		print("WIN")

func spawn_enemy():
	if enemiesInWave>0:
		enemiesInWave-=1
		var new_enemy: Enemy = spawnableEnemies.pick_random().instantiate() as Enemy
		new_enemy.position = position
		new_enemy.spawner = self
		get_parent().add_child(new_enemy)
