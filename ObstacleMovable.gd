# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var obstacle_area
var collision_radius : float = 20.0
var obstacle_nav_radius : float = 15.0

var nav_agent : NavigationAgent2D #not currently used
var nav_obstacle : NavigationObstacle2D

var level_scene

var selected = false

func _ready():
	obstacle_area = $Area2D
	obstacle_area.connect("input_event", self, "_on_area_input_event")
	obstacle_area.get_node("CollisionShape2D").shape.radius = collision_radius
	nav_agent = $NavAgent #not currently used
	nav_agent.avoidance_enabled = false #not currently used
	nav_obstacle = $NavObstacle
	nav_obstacle.estimate_radius = false
	nav_obstacle.radius = obstacle_nav_radius
	
# init called by parent, inits flow down from parent nodes to create easy parent child references
func init_obstacle(parent_level_scene):
	level_scene = parent_level_scene
	# Workaround to set NavigationObstacle2D navigation map properly until PR gets fixed in 3.5
	# https://github.com/godotengine/godot/issues/64185
	Navigation2DServer.agent_set_map(nav_obstacle.get_rid(), get_world_2d().get_navigation_map())
	Navigation2DServer.agent_set_radius(nav_obstacle.get_rid(), obstacle_nav_radius)

func _process(delta):
	if selected:
		self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), get_global_mouse_position())

func _on_area_input_event(event_viewport : Node, event : InputEvent, event_shape_index : int):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				level_scene.obstacle_selected = true
				self.selected = true
		else:
			if level_scene.obstacle_selected:
				level_scene.obstacle_selected = false
				selected = false
				self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), get_global_mouse_position())
