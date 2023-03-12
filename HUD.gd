# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

class_name Hud

@onready var debug_menu : Node2D = get_node("DebugMenu")

func _ready() -> void:
	pass

func enable_hud() -> void:
	visible = true

func set_version_hud(version_to_set : String) -> void:
	debug_menu.get_node("ControllerHints").text = "v" + version_to_set + "\n" + debug_menu.get_node("ControllerHints").text
