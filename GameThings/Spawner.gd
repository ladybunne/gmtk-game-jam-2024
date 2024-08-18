class_name Spawner extends Node2D

@onready var next_spawn_timer: Timer = %NextSpawnTimer
@onready var next_wave_timer: Timer = %NextWaveTimer

@export var enemy_to_spawn: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_spawn_timer.timeout.connect(spawn_enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_enemy():
	var new_enemy: Enemy = enemy_to_spawn.instantiate() as Enemy
	new_enemy.position = position
	new_enemy.spawner = self
	get_parent().add_child(new_enemy)
