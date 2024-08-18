# Inspired by Fire Emblem / Advance Wars!
extends CanvasLayer

@onready var margin_container: MarginContainer = %MarginContainer

# Don't use TOP_LEFT or BOTTOM_LEFT, there's other stuff there.
enum AnchorPosition { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT }

@export var anchor_position: AnchorPosition = AnchorPosition.BOTTOM_LEFT :
	set(p_anchor_position):
		anchor_position = p_anchor_position
		if margin_container != null:
			reposition()

func reposition():
	print("asdf")
	match anchor_position:
		AnchorPosition.TOP_LEFT:
			margin_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		AnchorPosition.TOP_RIGHT:
			margin_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		AnchorPosition.BOTTOM_LEFT:
			margin_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		AnchorPosition.BOTTOM_RIGHT:
			margin_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)

# For testing.
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#anchor_position = AnchorPosition.values()[(anchor_position + 1) % 4]
