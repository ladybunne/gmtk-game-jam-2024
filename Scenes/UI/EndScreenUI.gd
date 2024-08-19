class_name EndScreenUI extends CanvasLayer

@onready var button: Button = %Button

@export var win: bool = true :
	set(p_win):
		win = p_win
		if get_node_or_null("%Outcome"):
			%Outcome.text = "You win!" if win else "You lose..."

func _ready() -> void:
	%Button.pressed.connect(clicked)
	
func clicked():
	print("clicked")
