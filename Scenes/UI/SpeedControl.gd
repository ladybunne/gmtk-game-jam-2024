extends CanvasLayer

# And this is why I don't like @onready.
@onready var speed_one: Button = $MarginContainer/HBoxContainer/One
@onready var speed_two: Button = $MarginContainer/HBoxContainer/Two
@onready var speed_three: Button = $MarginContainer/HBoxContainer/Three
@onready var speed_four: Button = $MarginContainer/HBoxContainer/Four

var active_button: Button :
	set(p_active_button):
		if active_button != null:
			active_button.disabled = false
		active_button = p_active_button
		if active_button != null:
			active_button.disabled = true

func _ready() -> void:
	active_button = speed_one
	# I prefer connecting stuff like this because you can see it easily.
	speed_one.pressed.connect(one_pressed)
	speed_two.pressed.connect(two_pressed)
	speed_three.pressed.connect(three_pressed)
	speed_four.pressed.connect(four_pressed)

# This is terrible. Oh well!
func one_pressed():
	Engine.time_scale = 1
	active_button = speed_one

func two_pressed():
	Engine.time_scale = 2
	active_button = speed_two

func three_pressed():
	Engine.time_scale = 3
	active_button = speed_three

func four_pressed():
	Engine.time_scale = 4
	active_button = speed_four
