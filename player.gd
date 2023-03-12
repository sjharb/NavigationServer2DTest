# Author : Shaun Harbison
# MIT License : 2022

extends CharacterBody2D

class_name PlayerNavAgent

var level_scene : Node2D

@onready var nav_agent : NavigationAgent2D = get_node("NavigationAgent2D")

@export var nav_agent_radius : float = 15.0
@export var nav_optimize_path : bool = false
@export var nav_avoidance_enabled : bool = true
@export var player_speed_multiplier : float = 50.0
@export var keep_closest_point_in_nav: bool = true

# final navigation destination position/point
var nav_destination : Vector2 
# next navigation destination position/point
var next_nav_position : Vector2 

# The normal path to the destination
var player_nav_path : Array = []

# The actual path being calcuated during travel, used in the draw function
var player_real_nav_path : Array = []

func init():
	# Using floating motion mode.
	# Top-down perspective so the character is not using gravity.
	self.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _ready() -> void:
	# Cnit velocity
	# Vector2.ZERO is enumeration for Vector2(0,0)
	velocity = Vector2.ZERO
	
	# Connect nav agent signal callback functions.
	nav_agent.connect("path_changed",Callable(self,"character_path_changed"))
	nav_agent.connect("target_reached",Callable(self,"character_target_reached_reached"))
	nav_agent.connect("navigation_finished",Callable(self,"character_navigation_finished"))
	nav_agent.connect("velocity_computed",Callable(self,"character_velocity_computed"))
	# config nav agent attributes
	nav_agent.max_speed = player_speed_multiplier
	nav_agent.radius = nav_agent_radius
	nav_agent.avoidance_enabled = nav_avoidance_enabled

# init called by parent, inits flow down from parent nodes to create easy parent child references
func init_player(parent_level_scene : Node2D, instanced_in_code : bool) -> void:
	# set the level_scene easy reference as the init calling level scene
	level_scene = parent_level_scene
	
	# init positions
	if instanced_in_code:
		# init position(s) for player existing in the level scene during start
		if keep_closest_point_in_nav:
			# find closest point clicked in the nav
			global_position = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), level_scene.previous_right_mouse_click_global_position)
			nav_destination = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), level_scene.previous_left_mouse_click_global_position)
			next_nav_position = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), level_scene.previous_right_mouse_click_global_position)
		else:
			global_position = level_scene.previous_right_mouse_click_global_position
			nav_destination = level_scene.previous_left_mouse_click_global_position
			next_nav_position = level_scene.previous_right_mouse_click_global_position
	else:
		# init position(s) for player scenes created during play
		nav_destination = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), global_position)
		next_nav_position = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), global_position)
		
	# set the initial target location to nav_destination
	nav_agent.set_target_position(nav_destination)

func _physics_process(_delta : float) -> void:
	# get the next nav position from the player's navigation agent
	next_nav_position = nav_agent.get_next_path_position()
	# add the next nav position to the 'real' path for draw function
	player_real_nav_path.push_back(next_nav_position)
	# calculate the desired velocity, i.e velocity pre nav server calculated
	var desired_velocity = global_position.direction_to(next_nav_position) * player_speed_multiplier
	
	# feed the desired into the navigation agent 
	# set_velocity will trigger a callback from velocity_computed signal
	nav_agent.set_velocity(desired_velocity)
	
func set_navigation_position(nav_position_to_set : Vector2) -> void:
	nav_destination = nav_position_to_set
	
	# set the new player target location
	nav_agent.set_target_position(nav_destination)
	
	# calculate a new map path with the server using player nav agent map and new nav destination
	player_nav_path = NavigationServer2D.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path)
	
	# clear the old real nav path, used for draw function
	player_real_nav_path.clear()

func character_path_changed() -> void:
	# TODO, implement this function to add behavior for player
	pass
	
func character_target_reached_reached() -> void:
	# TODO, implement this function to add behavior for player
	# currently using is_target_reached() in character_velocity_computed()
	pass
	
func character_navigation_finished() -> void:
	# TODO, implement this function to add behavior for player
	pass
	
func character_velocity_computed(calculated_velocity : Vector2) -> void:
	# check if nav agent target is reached
	if !nav_agent.is_target_reached():
		# move and slide with the new calculated velocity
		set_velocity(calculated_velocity)
		move_and_slide()
	else:
		# TODO, implement logic for when the player reaches the target.
		pass
		# if reached target, stand at the closest point in the navigation map
#		global_position = NavigationServer2D.map_get_closest_point(nav_agent.get_navigation_map(), global_position)


