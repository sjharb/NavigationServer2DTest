# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var characters = []
var level_camera
var main
var obstacles = []

var obstacle_selected = false

var previous_left_mouse_click_global_position : Vector2
var previous_right_mouse_click_global_position : Vector2

var move_camera_with_mouse = false

var character_creation_timer : Timer = Timer.new()
var character_creation_timer_wait_time : float = 0.15

var mouse_move_drift_weight : float = 100.0

func _ready():
	level_camera = $LevelCamera
	
	character_creation_timer.one_shot = true
	character_creation_timer.wait_time = character_creation_timer_wait_time
	add_child(character_creation_timer)

func init(level_parent_scene):
	main = level_parent_scene
	
	init_pre_existing_level_characters()
	init_pre_existing_level_obstacles()
	
func init_pre_existing_level_characters():
	for child_node in get_children():
		if child_node is KinematicBody2D:
			if child_node.has_method("init_character"):
				child_node.init_character(self, false)
				characters.push_back(child_node)

func init_pre_existing_level_obstacles():
	for child_node in get_children():
		if child_node is Node2D:
			if child_node.has_method("init_obstacle"):
				child_node.init_obstacle(self)
				obstacles.push_back(child_node)

func move_camera_with_players():
	if !characters.empty():
		level_camera.global_position = characters[0].global_position

func _process(delta):
	update()

func _draw():
	# TODO: these is some clean up to do, with regards to random draw errors
	for character in characters:
		if character is KinematicBody2D and is_instance_valid(character) and character.is_inside_tree():
			if character.character_nav_path.size() > 1:
				var previous_line_point : Vector2 = character.character_nav_path[1]
				for path_index in range(1, character.character_nav_path.size()):
					var line_point : Vector2 = character.character_nav_path[path_index]
					if previous_line_point is Vector2 and line_point is Vector2 and previous_line_point.distance_to(line_point) > 1.0:
						draw_line(previous_line_point, line_point, Color(1.0, 0.3, 0.7, 1.0), 3.0, false)
						draw_circle(line_point, 4.0, Color(0.1, 5.0, 0.6, 1.0))
					previous_line_point = line_point
			
			if character.character_real_nav_path.size() > 1:
				var previous_line_point : Vector2 = character.character_real_nav_path[0]
				for path_index in range(1, character.character_real_nav_path.size()):
					var line_point : Vector2 = character.character_real_nav_path[path_index]
					if previous_line_point is Vector2 and line_point is Vector2 and previous_line_point.distance_to(line_point) > 1.0:
						draw_line(previous_line_point, line_point, Color(0.6, 0.6, 0.2, 1.0), 3.0, false)
						draw_circle(line_point, 4.0, Color(0.3, 0.8, 0.2, 1.0))
					previous_line_point = line_point
			
			draw_circle(character.next_nav_position, 10.0, Color(0.5, 1.0, 0.1, 1.0))
			if character.global_position.distance_to(character.next_nav_position) > 1.0:
				draw_line(character.global_position, character.next_nav_position, Color(1.0, 0.6, 0.8, 1.0), 5.0, false)
			
			draw_circle(character.global_position, character.nav_agent.radius, Color(1.0, 0.0, 0.3, 1.0))
			
			draw_circle(character.nav_destination, character.nav_agent.radius, Color(0.7, 0.5, 0.2, 1.0))
			
			if character.global_position.distance_to(character.velocity) > 1.0:
				draw_line(character.global_position, character.global_position + character.velocity, Color(0.3, 0.5, 1.0, 1.0), 3.0, false)
			draw_circle(character.global_position + character.velocity, 5.0, Color(0.2, 0.5, 0.7, 1.0))
	
	for obstacle in obstacles:
		if obstacle is Node2D and is_instance_valid(obstacle) and obstacle.is_inside_tree():
			draw_circle(obstacle.global_position, obstacle.collision_radius, Color(0.5, 0.6, 0.4, 1.0))
	
	if level_camera is Camera2D and is_instance_valid(level_camera) and level_camera.is_inside_tree():
		draw_line(level_camera.global_position, level_camera.camera_target_position, Color(0.3, 0.7, 0.1, 1.0), false)
	
func create_character():
	var new_character = load("res://Character.tscn")
	var new_character_scene = new_character.instance()
	add_child(new_character_scene)
	new_character_scene.init_character(self, true)
	characters.push_back(new_character_scene)

func mouse_left_press():
	if !obstacle_selected:
		previous_left_mouse_click_global_position = get_global_mouse_position()
		for character in characters:
			character.set_navigation_position(get_global_mouse_position())

func mouse_left_release():
	obstacle_selected = false
	
func mouse_right_press():
	if character_creation_timer.is_stopped():
		previous_right_mouse_click_global_position = get_global_mouse_position()
		call_deferred("create_character")
		character_creation_timer.start()
	
func mouse_right_release():
	pass

func mouse_middle_press():
	move_camera_with_mouse = true
	level_camera.set_target_position(get_global_mouse_position())
	
func mouse_middle_release():
	if move_camera_with_mouse:
		move_camera_with_mouse = false
		level_camera.set_target_position(level_camera.global_position + level_camera.global_position.direction_to(get_global_mouse_position()) * mouse_move_drift_weight)
	
func mouse_middle_wheel_down():
	level_camera.zoom_out()
	
func mouse_middle_wheel_up():
	level_camera.zoom_in()

func mouse_motion():
	if move_camera_with_mouse:
		level_camera.set_target_position(get_global_mouse_position())
