# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

class_name NavObstacle

@onready var obstacle_area: Area2D = get_node("Area2D")
@onready var nav_obstacle : NavigationObstacle2D = get_node("NavObstacle")

var collision_radius : float = 20.0
var obstacle_nav_radius : float = 15.0

var level_scene

var selected = false

func _ready() -> void:
	obstacle_area.connect("input_event",Callable(self,"_on_area_input_event"))
	obstacle_area.get_node("CollisionShape2D").shape.radius = collision_radius
	nav_obstacle.estimate_radius = false
	nav_obstacle.radius = obstacle_nav_radius
	
# init called by parent, inits flow down from parent nodes to create easy parent child references
func init_obstacle(parent_level_scene) -> void:
	level_scene = parent_level_scene

func _process(_delta : float) -> void:
	if selected:
		global_position = NavigationServer2D.map_get_closest_point(level_scene.level_navigation_map, get_global_mouse_position())

func _on_area_input_event(_event_viewport : Node, event : InputEvent, _event_shape_index : int) -> void:
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
