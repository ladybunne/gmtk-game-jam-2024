extends Control

@export var camera: Camera2D
var down: bool = false
var start_position: Vector2 = Vector2.ZERO
var start_viewport_posiiton: Vector2 = Vector2.ZERO

var zoom_limit_min: float = 0.5
var zoom_limit_max: float = 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Scroll down / zoom out
		if event.button_index == 4:
			camera.zoom += Vector2(0.1, 0.1)
			start_position = camera.position
			start_viewport_posiiton = event.position
		
		# Scroll up / zoom in
		elif event.button_index == 5:
			camera.zoom -= Vector2(0.1, 0.1)
			start_position = camera.position
			start_viewport_posiiton = event.position
			
		elif event.button_index == 2 or event.button_index == 3:
			down = event.pressed
			start_position = camera.position
			start_viewport_posiiton = event.position
		
		else:
			return
	
		camera.zoom.x = clamp(camera.zoom.x, zoom_limit_min, zoom_limit_max)
		camera.zoom.y = clamp(camera.zoom.y, zoom_limit_min, zoom_limit_max)

func _process(delta: float) -> void:
	if down:
		camera.position = start_position + (start_viewport_posiiton - get_viewport().get_mouse_position()) * Vector2(1.0 / camera.zoom.x, 1.0 / camera.zoom.y)
