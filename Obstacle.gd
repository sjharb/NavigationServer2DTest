# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var obstacle_area
var collision_radius : float = 20.0
var obstacle_nav_radius : float = 15.0

var nav_obstacle : NavigationObstacle2D

var level_scene

var selected = false

func _ready() -> void:
	obstacle_area = $Area2D
	obstacle_area.connect("input_event",Callable(self,"_on_area_input_event"))
	obstacle_area.get_node("CollisionShape2D").shape.radius = collision_radius
	nav_obstacle = $NavObstacle
	nav_obstacle.estimate_radius = false
	nav_obstacle.radius = obstacle_nav_radius
	
# init called by parent, inits flow down from parent nodes to create easy parent child references
func init_obstacle(parent_level_scene) -> void:
	level_scene = parent_level_scene
	# START WORKAROUND -------------------------------------------------------------
	# Workaround to set NavigationObstacle2D navigation map properly until PR gets fixed in 3.5
	# Update: Fix is cherry picked for Godot v3.5.2
	# https://github.com/godotengine/godot/issues/64185
	# Fix: https://github.com/godotengine/godot/pull/66530
	var engine_info : Dictionary = Engine.get_version_info()
	var major = engine_info.get("major")
	var minor = engine_info.get("minor")
	var patch = engine_info.get("patch")

	var nav_fix_66530_applied = true
	if major <= int(3) and minor <= int(5) and patch <= int(1):
		nav_fix_66530_applied = false
	
	if not nav_fix_66530_applied:
		NavigationServer2D.agent_set_map(nav_obstacle.get_rid(), get_world_2d().get_navigation_map())
		NavigationServer2D.agent_set_radius(nav_obstacle.get_rid(), obstacle_nav_radius)
	# END WORKAROUND -------------------------------------------------------------

func _process(_delta : float) -> void:
	if selected:
		global_position = NavigationServer2D.map_get_closest_point(level_scene.level_navigation_map, get_global_mouse_position())

func _on_area_input_event(event_viewport : Node, event : InputEvent, event_shape_index : int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				level_scene.obstacle_selected = true
				selected = true
		else:
			if level_scene.obstacle_selected:
				level_scene.obstacle_selected = false
				selected = false
				global_position = NavigationServer2D.map_get_closest_point(level_scene.level_navigation_map, get_global_mouse_position())
