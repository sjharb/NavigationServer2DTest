# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

class_name Hud

@onready var controller_hints : Label = get_node("HudText/ControllerHints")

func _ready() -> void:
	pass

func enable_hud() -> void:
	visible = true

func set_version_hud(version_to_set : String) -> void:
	controller_hints.text = "v" + version_to_set + "\n" + controller_hints.text
