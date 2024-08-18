extends Node

var buildResource = 100
var areaToBuildResourceRatio = 1.0/1024.0

var funding = 10 :
	set(p_funding):
		funding = p_funding
		funding_changed.emit(funding)

signal funding_changed(funding: int)

func _ready() -> void:
	pass
