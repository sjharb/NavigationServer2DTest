# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var debug_menu : Node2D

func _ready() -> void:
	debug_menu = $DebugMenu

func enable_hud() -> void:
	self.visible = true

func set_version_hud(version_to_set):
	debug_menu.get_node("ControllerHints").text = "v" + version_to_set + "\n" + debug_menu.get_node("ControllerHints").text
