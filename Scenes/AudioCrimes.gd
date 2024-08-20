class_name AudioCrimes extends Node

@export var normal_volume: int = -8 :
	set(p_normal_volume):
		normal_volume = p_normal_volume
		if is_node_ready():
			update_players()

func _ready() -> void:
	update_players()

func _process(delta: float) -> void:
	%Chip.on = get_tree().get_node_count_in_group("Tower") >= 5
	%Bass.on = get_tree().get_node_count_in_group("Tower") >= 3
	%Lead.on = get_tree().get_node_count_in_group("Tower") >= 1

	%Hat.on = get_tree().get_node_count_in_group("Enemy") >= 1
	
	# Check for a boss enemy
	%IntenseDrums.on = false
	if %IntenseDrums.on:
		# Maybe turn off hat at the same time.
		%Hat.on = false
	
	# Change which lead is playing based on pools.
	# Ideally whichever one you place most recently is the one that works.
	%HighLead.on = false
	%LowLead.on = false
	
	if %HighLead.on or %LowLead.on:
		%Lead.on = false

func update_players():
	%Base.on_volume = normal_volume
	%Bass.on_volume = normal_volume
	%Chip.on_volume = normal_volume
	%Hat.on_volume = normal_volume
	%HighLead.on_volume = normal_volume
	%IntenseDrums.on_volume = normal_volume
	%Lead.on_volume = normal_volume
	%LowLead.on_volume = normal_volume
