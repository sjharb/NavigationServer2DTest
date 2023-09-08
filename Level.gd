# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

class_name Level

var main
var players: Array[PlayerNavAgent] = []
var obstacles: Array[NavObstacle] = []

@onready var player_resource = preload("res://player.tscn")

var level_navigation_map

#var level_tile_map : TileMap

var obstacle_selected = false

var previous_left_mouse_click_global_position: Vector2
var previous_right_mouse_click_global_position: Vector2

@onready var level_camera: Camera2D = get_node("LevelCamera")
var level_camera_move_with_mouse = false
var level_camera_mouse_move_drift_weight: float = 20.0

var player_creation_time_limit_timer: Timer = Timer.new()
@export var player_creation_time_limit_timer_wait_time: float = 0.15

@export var level_edge_connection_margin: float = 20.0

func _ready() -> void:
	# create easy reference variables for children
	
	# If using tilemap:
	#level_tile_map = $LevelTileMap
	#level_tile_map = $LevelNavigationPolygonInstance
	
	level_navigation_map = get_world_2d().get_navigation_map()
	
	NavigationServer2D.map_set_edge_connection_margin(level_navigation_map, 10.0)
	
	# configure and add the player_creation_time_limit_timer as a child of the level
	player_creation_time_limit_timer.one_shot = true
	player_creation_time_limit_timer.wait_time = player_creation_time_limit_timer_wait_time
	add_child(player_creation_time_limit_timer)

# init called by parent, inits flow down from parent nodes to create easy parent child references
func init(level_parent_scene) -> void:
	main = level_parent_scene
	init_pre_existing_level_players()
	init_pre_existing_level_obstacles()
	
func init_pre_existing_level_players() -> void:
	# init all the player scenes in the scene tree when starting the level
	# other players created in create_player() will be initilized at that time
	for child_node in get_children():
		if child_node is CharacterBody2D:
			if child_node.has_method("init_player"):
				if players.is_empty():
					# if no target i.e. left mouse click yet, set target to player position
					previous_left_mouse_click_global_position = child_node.global_position
				child_node.init_player(self, false)
				players.push_back(child_node)
				

func init_pre_existing_level_obstacles() -> void:
	# init all the obstacle scenes in the scene tree when starting the level
	for child_node in get_children():
		if child_node is Node2D: # obstacles are currently Node2D
			if child_node.has_method("init_obstacle"):
				child_node.init_obstacle(self)
				obstacles.push_back(child_node)

# TODO, add option for camera player following
func move_camera_with_players() -> void:
	if !players.is_empty():
		level_camera.global_position = players[0].global_position

func _process(_delta : float) -> void:
	# update for the draw function
	queue_redraw()

func _draw() -> void:
	for player in players:
		if player is CharacterBody2D and is_instance_valid(player) and player.is_inside_tree():
			if player.player_real_nav_path.size() > 1:
				var previous_line_point : Vector2 = player.player_real_nav_path[1]
				for path_index in range(1, player.player_real_nav_path.size()):
					var line_point : Vector2 = player.player_real_nav_path[path_index]
					if previous_line_point is Vector2 and line_point is Vector2 and previous_line_point.distance_to(line_point) > 2.0:
						draw_line(previous_line_point,line_point,Color(1.0, 0.3, 0.7, 1.0),3.0)
						draw_circle(line_point, 4.0, Color(0.1, 5.0, 0.6, 1.0))
					previous_line_point = line_point
			
			if player.player_real_nav_path.size() > 1:
				var previous_line_point : Vector2 = player.player_real_nav_path[0]
				for path_index in range(1, player.player_real_nav_path.size()):
					var line_point : Vector2 = player.player_real_nav_path[path_index]
					if previous_line_point is Vector2 and line_point is Vector2 and previous_line_point.distance_to(line_point) > 2.0:
						draw_line(previous_line_point,line_point,Color(0.6, 0.6, 0.2, 1.0),3.0)
						draw_circle(line_point, 4.0, Color(0.3, 0.8, 0.2, 1.0))
					previous_line_point = line_point
			
			draw_circle(player.next_nav_position, 10.0, Color(0.5, 1.0, 0.1, 1.0))
			if player.global_position.distance_to(player.next_nav_position) > 1.0:
				draw_line(player.global_position,player.next_nav_position,Color(1.0, 0.6, 0.8, 1.0),5.0)
			
			draw_circle(player.global_position, player.nav_agent.radius, Color(1.0, 0.0, 0.3, 1.0))
			
			draw_circle(player.nav_destination, player.nav_agent.radius, Color(0.7, 0.5, 0.2, 1.0))
			
			if player.global_position.distance_to(player.velocity) > 2.0:
				draw_line(player.global_position,player.global_position + player.velocity,Color(0.3, 0.5, 1.0, 1.0),3.0)
			draw_circle(player.global_position + player.velocity, 5.0, Color(0.2, 0.5, 0.7, 1.0))
	
	for obstacle in obstacles:
		if obstacle is Node2D and is_instance_valid(obstacle) and obstacle.is_inside_tree():
			draw_circle(obstacle.global_position, obstacle.obstacle_nav_radius, Color(0.5, 0.6, 0.4, 1.0))
	
	if level_camera is Camera2D and is_instance_valid(level_camera) and level_camera.is_inside_tree():
		draw_line(level_camera.global_position, level_camera.camera_target_position, Color(0.3, 0.7, 0.1, 1.0), false)

# Create a new instance of the Character scene
func create_player() -> void:
	var new_player_scene = player_resource.instantiate()
	add_child(new_player_scene)
	# init after adding as child of the level
	new_player_scene.init_player(self, true)
	# store the player scene reference in the level player array
	players.push_back(new_player_scene)

func mouse_left_press() -> void:
	if !obstacle_selected:
		previous_left_mouse_click_global_position = get_global_mouse_position()
		# set all level players new navigation position
		for player in players:
			player.set_navigation_position(get_global_mouse_position())

func mouse_left_release() -> void:
	obstacle_selected = false
	
func mouse_right_press() -> void:
	if player_creation_time_limit_timer.is_stopped():
		previous_right_mouse_click_global_position = get_global_mouse_position()
		call_deferred("create_player")
		player_creation_time_limit_timer.start()
	
func mouse_right_release() -> void:
	pass

func mouse_middle_press() -> void:
	level_camera_move_with_mouse = true
	level_camera.set_target_position(get_global_mouse_position())
	
func mouse_middle_release() -> void:
	if level_camera_move_with_mouse:
		level_camera_move_with_mouse = false
		level_camera.set_target_position(level_camera.global_position + level_camera.global_position.direction_to(get_global_mouse_position()) * level_camera_mouse_move_drift_weight)
	
func mouse_middle_wheel_down() -> void:
	level_camera.zoom_out()
	
func mouse_middle_wheel_up() -> void:
	level_camera.zoom_in()

func mouse_motion() -> void:
	if level_camera_move_with_mouse:
		level_camera.set_target_position(get_global_mouse_position())
