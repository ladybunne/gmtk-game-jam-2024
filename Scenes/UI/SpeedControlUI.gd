extends CanvasLayer

var active_button: Button :
	set(p_active_button):
		if active_button != null:
			active_button.disabled = false
		active_button = p_active_button
		if active_button != null:
			active_button.disabled = true

func _ready() -> void:
	active_button = %One
	# I prefer connecting stuff like this because you can see it easily.
	%Tenth.pressed.connect(tenth_pressed)
	%Half.pressed.connect(half_pressed)
	%One.pressed.connect(one_pressed)
	%Two.pressed.connect(two_pressed)
	%Four.pressed.connect(four_pressed)

# This is terrible. Oh well!
func tenth_pressed():
	Engine.time_scale = 0.1
	active_button = %Tenth
	
func half_pressed():
	Engine.time_scale = 0.5
	active_button = %Half

func one_pressed():
	Engine.time_scale = 1
	active_button = %One

func two_pressed():
	Engine.time_scale = 2
	active_button = %Two

func four_pressed():
	Engine.time_scale = 4
	active_button = %Four
