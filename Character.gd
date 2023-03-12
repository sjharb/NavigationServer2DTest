# Author : Shaun Harbison
# MIT License : 2022

extends KinematicBody2D

var level_scene : Node2D

var nav_agent : NavigationAgent2D

export var nav_agent_radius : float = 15.0
export var nav_optimize_path : bool = false
export var nav_avoidance_enabled : bool = true
export var character_speed_multiplier : float = 50.0

var velocity : Vector2

# final navigation destination position/point
var nav_destination : Vector2 
# next navigation destination position/point
var next_nav_position : Vector2 

# The normal path to the destination
var character_nav_path : Array = []

# The actual path being calcuated during travel, used in the draw function
var character_real_nav_path : Array = []

func _ready() -> void:
	# init velocity
	# Vector2.ZERO is enumeration for Vector2(0,0)
	velocity = Vector2.ZERO 
	
	nav_agent = $NavigationAgent2D
	# connect nav agent signal callback functions
	nav_agent.connect("path_changed", self, "character_path_changed")
	nav_agent.connect("target_reached", self, "character_target_reached_reached")
	nav_agent.connect("navigation_finished", self, "character_navigation_finished")
	nav_agent.connect("velocity_computed", self, "character_velocity_computed")
	# config nav agent attributes
	nav_agent.max_speed = character_speed_multiplier
	nav_agent.radius = nav_agent_radius
	nav_agent.avoidance_enabled = nav_avoidance_enabled

# init called by parent, inits flow down from parent nodes to create easy parent child references
func init_character(parent_level_scene : Node2D, instanced_in_code : bool) -> void:
	# set the level_scene easy reference as the init calling level scene
	level_scene = parent_level_scene
	
	# init positions
	if instanced_in_code:
		# init position(s) for character existing in the level scene during start
		global_position = level_scene.previous_right_mouse_click_global_position
		nav_destination = level_scene.previous_left_mouse_click_global_position
		next_nav_position = level_scene.previous_right_mouse_click_global_position
	else:
		# init position(s) for character scenes created during play
		nav_destination = global_position
		next_nav_position = global_position
		
	# set the initial target location to nav_destination
	nav_agent.set_target_location(nav_destination)

func _physics_process(_delta : float) -> void:
	# get the next nav position from the character's navigation agent
	next_nav_position = nav_agent.get_next_location()
	# add the next nav position to the 'real' path for draw function
	character_real_nav_path.push_back(next_nav_position)
	# calculate the desired velocity, i.e velocity pre nav server calculated
	var desired_velocity = global_position.direction_to(next_nav_position) * character_speed_multiplier
	
	# feed the desired into the navigation agent 
	# set_velocity will trigger a callback from velocity_computed signal
	nav_agent.set_velocity(desired_velocity)
	
func set_navigation_position(nav_position_to_set : Vector2) -> void:
	nav_destination = nav_position_to_set
	
	# set the new character target location
	nav_agent.set_target_location(nav_destination)
	
	# calculate a new map path with the server using character nav agent map and new nav destination
	character_nav_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path)
	
	# clear the old real nav path, used for draw function
	character_real_nav_path.clear()

func character_path_changed() -> void:
	# TODO, implement this function to add behavior for character
	pass
	
func character_target_reached_reached() -> void:
	# TODO, implement this function to add behavior for character
	# currently using is_target_reached() in character_velocity_computed()
	pass
	
func character_navigation_finished() -> void:
	# TODO, implement this function to add behavior for character
	pass
	
func character_velocity_computed(calculated_velocity : Vector2) -> void:
	velocity = calculated_velocity
	
	# check if nav agent target is reached
	if !nav_agent.is_target_reached():
		# move and slide with the new calculated velocity
		#global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position)
		velocity = move_and_slide(velocity)
	else:
		# if reached target, stand at the closest point in the navigation map
		global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position)


