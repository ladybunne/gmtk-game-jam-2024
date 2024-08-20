class_name AudioCrimes extends Node

var crazyJams: bool = false
var theTime: float = 0
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
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.filter(func(enemy): return enemy.type in [UnitData.UnitType.Armoured, UnitData.UnitType.Hardening, UnitData.UnitType.Pinata]):
		%IntenseDrums.on = true
		# Maybe turn off hat at the same time.
		%Hat.on = false
	else:
		%IntenseDrums.on = false

	# Change which lead is playing based on pools.
	# Ideally whichever one you place most recently is the one that works.
	%HighLead.on = false
	%LowLead.on = false

	var pools = get_tree().get_nodes_in_group("Pool")
	if pools.size():
		var latest_pool = pools[-1] as Pool
		%HighLead.on = !latest_pool.grow
		%LowLead.on = latest_pool.grow
		%Lead.on = false
	else:
		%HighLead.on = false
		%LowLead.on = false


	#EXPERIMENTAL COOL THING TO FLIP TIME IN REAL TIME REGARDLESS OF TIMESCALE! Suckit time.
	#var pools = get_tree().get_nodes_in_group("Pool")
	#var hasSmol: bool = false
	#var hasBig: bool = false
	#if pools.size():
		#for pool in pools:
			#if pool.grow:
				#hasBig = true
			#if !pool.grow:
				#hasSmol = true
		#if hasBig && hasSmol:
			#crazyJams = true
		#else:
			#crazyJams = false
		#if !crazyJams:
			#var latest_pool = pools[-1] as Pool
			#%HighLead.on = !latest_pool.grow
			#%LowLead.on = latest_pool.grow
			#%Lead.on = false
	#else:
		#%HighLead.on = false
		#%LowLead.on = false
	#if theTime < (Time.get_ticks_msec()/1000)-2:
		#theTime = (Time.get_ticks_msec()/1000)
		#makeCrazyJams()

func makeCrazyJams():
	if crazyJams:
		print("switch crazy jams!")
		%HighLead.on = !%HighLead.on
		%LowLead.on = !%LowLead.on


func update_players():
	%Base.on_volume = normal_volume
	%Bass.on_volume = normal_volume
	%Chip.on_volume = normal_volume
	%Hat.on_volume = normal_volume
	%HighLead.on_volume = normal_volume
	%IntenseDrums.on_volume = normal_volume
	%Lead.on_volume = normal_volume
	%LowLead.on_volume = normal_volume
