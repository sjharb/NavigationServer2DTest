# Author : Shaun Harbison
# MIT License : 2022

extends KinematicBody2D

var nav_agent : NavigationAgent2D
var velocity : Vector2

var nav_optimize_path = false

var nav_destination : Vector2

var character_speed_multiplier : float = 50.0

var character_nav_path = []
var character_real_nav_path = []

var next_nav_position : Vector2

var level_scene : Node2D

func _ready():
	velocity = Vector2(0,0)
	nav_destination = self.global_position
	next_nav_position = self.global_position
	nav_agent = $NavigationAgent2D
	nav_agent.connect("path_changed", self, "character_path_changed")
	nav_agent.connect("target_reached", self, "character_target_reached_reached")
	nav_agent.connect("navigation_finished", self, "character_navigation_finished")
	nav_agent.connect("velocity_computed", self, "character_velocity_computed")
	nav_agent.max_speed = character_speed_multiplier
	nav_agent.radius = 15.0
	nav_agent.avoidance_enabled = true
	nav_agent.set_target_location(nav_destination)

func init_character(parent_level_scene, instanced_in_code : bool):
	level_scene = parent_level_scene
	if instanced_in_code:
		self.global_position = level_scene.previous_right_mouse_click_global_position
		set_navigation_position(level_scene.previous_left_mouse_click_global_position)

func _physics_process(delta : float) -> void:
	next_nav_position = nav_agent.get_next_location()
	character_real_nav_path.push_back(next_nav_position)
	velocity = self.global_position.direction_to(next_nav_position) * character_speed_multiplier
	
	nav_agent.set_velocity(velocity)
	
func set_navigation_position(nav_position_to_set : Vector2):
	nav_destination = nav_position_to_set
	nav_agent.set_target_location(nav_destination)
	character_nav_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), self.global_position, nav_destination, nav_optimize_path)
	character_real_nav_path.clear()

func character_path_changed():
	pass
	
func character_target_reached_reached():
	pass
	
func character_navigation_finished():
	pass
	
func character_velocity_computed(new_velocity : Vector2):
	velocity = new_velocity
	if !nav_agent.is_target_reached():
		velocity = self.move_and_slide(velocity)
	else:
		self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position)


