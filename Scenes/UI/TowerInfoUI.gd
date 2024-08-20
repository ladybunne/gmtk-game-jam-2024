# Inspired by Fire Emblem / Advance Wars!
extends CanvasLayer

class_name TowerInfo

static var I

func _ready() -> void:
	I = self
	ammoTxt.hide()
	splashTxt.hide()
	reloadTxt.hide()
	
	nameTxt.text = ""
	damageTxt.text = ""
	rangeTxt.text = ""
	cdTxt.text = ""
	targetTxt.text = ""
	splashTxt.text = ""
	ammoTxt.text = ""
	reloadTxt.text = ""

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

@onready var nameTxt: RichTextLabel = %Name
@onready var damageTxt: RichTextLabel = %Damage
@onready var rangeTxt: RichTextLabel = %Range
@onready var cdTxt: RichTextLabel = %Cooldown
@onready var targetTxt: RichTextLabel = %Target
@onready var splashTxt: RichTextLabel = %Splash
@onready var ammoTxt: RichTextLabel = %Ammo
@onready var reloadTxt: RichTextLabel = %Reload
	

func Populate(type: TowerData.TowerType, damage: float, range: float, \
 cooldown: float, targetingMode: Tower.TargetingMode, splash: float, ammo: float, reload: float):
	splashTxt.hide()
	ammoTxt.hide()
	reloadTxt.hide()
	
	match type:
		TowerData.TowerType.Standard:
				nameTxt.text = "Standard Tower"
		TowerData.TowerType.Sniper:
				nameTxt.text = "Sniper Tower"
		TowerData.TowerType.Splash:
				nameTxt.text = "Splash Tower"
				splashTxt.show()
				splashTxt.text = "Splash Range: " + str(splash)
		TowerData.TowerType.Capacity:
				nameTxt.text = "Burst Tower"
				ammoTxt.show()
				ammoTxt.text = "Ammo Capacity: " + str(ammo)
				reloadTxt.show()
				reloadTxt.text = "Reload Time: " + str(reload)
		TowerData.TowerType.Embiggen:
				nameTxt.text = "Embiggen Tower"
		TowerData.TowerType.Ensmallen:
				nameTxt.text = "Ensmallen Tower"
		TowerData.TowerType.Debuff:
				nameTxt.text = "Slow Tower"
				splashTxt.show()
				splashTxt.text = "Slow: 40%"
	damageTxt.text = "Damage: " + str(damage)
	rangeTxt.text = "Range: " + str(range)
	cdTxt.text = "Cooldown: " + str(cooldown)
	match targetingMode:
		Tower.TargetingMode.FIRST:
			targetTxt.text = "Target: First"
		Tower.TargetingMode.LAST:
			targetTxt.text = "Target: Last"
		Tower.TargetingMode.CLOSE:
			targetTxt.text = "Target: Close"
		Tower.TargetingMode.STRONG:
			targetTxt.text = "Target: Strong"
