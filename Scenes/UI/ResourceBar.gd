extends TextureProgressBar

class_name ResourceBar

@export var preview: bool

static var mainBar: ResourceBar
static var previewBar: ResourceBar

func _ready() -> void:
	if preview:
		previewBar = self
	else:
		mainBar = self

func _process(delta: float) -> void:
	max_value = GameManager.barMax
	if !preview:
		value = GameManager.buildResource	
	
