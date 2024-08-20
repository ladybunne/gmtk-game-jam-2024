extends Node

@export var helpImageButton: Node

func _ready():
	$MarginContainer/HBoxContainer/Button.pressed.connect(_on_pressed)
func _on_pressed() -> void:
	#print("help")
	helpImageButton.show()
