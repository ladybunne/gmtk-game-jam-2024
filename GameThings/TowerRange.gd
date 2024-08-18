extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale = get_parent().get_parent().handle.scale;
	get_material().set_shader_parameter("scale",Vector2(scale.x,scale.y))
