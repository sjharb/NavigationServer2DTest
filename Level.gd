# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var characters = []
var level_camera
var main
var obstacles = []

func _ready():
	level_camera = $LevelCamera

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
	for character in characters:
		if character is KinematicBody2D and is_instance_valid(character) and character.is_inside_tree():
			if character.character_nav_path.size() > 1:
				var previous_line_point : Vector2 = character.character_nav_path[1]
				for path_index in range(1, character.character_nav_path.size()):
					var line_point : Vector2 = character.character_nav_path[path_index]
					if previous_line_point is Vector2 and line_point is Vector2 and previous_line_point.distance_to(line_point) > 1.0:
						draw_line(previous_line_point, line_point, Color(0.0, 0.0, 1.0, 1.0), 3.0, false)
						draw_circle(line_point, 4.0, Color(0.1, 5.0, 0.5, 1.0))
					previous_line_point = line_point
			
			if character.character_real_nav_path.size() > 1:
				var previous_line_point : Vector2 = character.character_real_nav_path[0]
				for path_index in range(1, character.character_real_nav_path.size()):
					var line_point : Vector2 = character.character_real_nav_path[path_index]
					if previous_line_point is Vector2 and line_point is Vector2 and previous_line_point.distance_to(line_point) > 1.0:
						draw_line(previous_line_point, line_point, Color(0.0, 0.6, 1.0, 1.0), 3.0, false)
						draw_circle(line_point, 4.0, Color(0.0, 1.0, 0.0, 1.0))
					previous_line_point = line_point
			
			draw_circle(character.next_nav_position, 10.0, Color(0.0, 1.0, 0.0, 1.0))
			draw_line(character.global_position, character.next_nav_position, Color(1.0, 0.6, 1.0, 1.0), 5.0, false)
			
			draw_circle(character.global_position, character.nav_agent.radius, Color(1.0, 0.0, 0.0, 1.0))
			
			draw_circle(character.nav_destination, character.nav_agent.radius, Color(1.0, 0.5, 0.0, 1.0))
			
			if character.velocity != Vector2.ZERO:
				draw_line(character.global_position, character.global_position + character.velocity, Color(1.0, 0.0, 1.0, 1.0), 3.0, false)
			draw_circle(character.global_position + character.velocity, 5.0, Color(0.9, 0.0, 0.3, 1.0))
	
	for obstacle in obstacles:
		draw_circle(obstacle.global_position, obstacle.collision_radius, Color(0.3, 0.2, 0.1, 1.0))
	
	draw_line(level_camera.global_position, level_camera.camera_target_position, Color(0.5, 0.7, 0.1, 1.0), false)

func create_character():
	var new_character = load("res://Character.tscn")
	var new_character_scene = new_character.instance()
	add_child(new_character_scene)
	new_character_scene.init_character(self, true)
	characters.push_back(new_character_scene)
