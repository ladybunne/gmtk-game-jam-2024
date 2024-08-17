extends TextureProgressBar

class_name ResourceBar

@export var preview: bool

static var previewBar: ResourceBar

func _ready() -> void:
	if preview:
		previewBar = self

func _process(delta: float) -> void:
	if !preview:
		value = GameManager.buildResource	
	
