class_name FadeableAudioStreamPlayer extends AudioStreamPlayer

@export var on: bool = false
@export var on_volume: float = 0
@export var off_volume: float = -40

@export var fade_time: float = 2.0

func _ready() -> void:
	volume_db = on_volume if on else off_volume

func _process(delta: float) -> void:
	if on:
		volume_db = clamp(volume_db + db_to_linear((on_volume - off_volume) * delta / (Engine.time_scale)), off_volume, on_volume)
	else:
		volume_db = clamp(volume_db - db_to_linear((on_volume - off_volume) * delta / (Engine.time_scale)), off_volume, on_volume)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_H:
			on = !on
