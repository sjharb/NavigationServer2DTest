# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var level_scene : Node2D
var hud : Node2D
var previous_left_mouse_click_global_position : Vector2
var previous_right_mouse_click_global_position : Vector2

var move_camera_with_mouse = false

var mouse_click_right_timer : Timer = Timer.new()
var mouse_click_right_wait_time : float = 0.01

var mouse_move_drift_weight : float = 100.0

var obstacle_mouse_pressed = false

func _ready():
	hud = $HUDCanvasLayer/HUD
	hud.enable_hud()
	level_scene = $Level
	level_scene.init(self)
	
	mouse_click_right_timer.one_shot = true
	mouse_click_right_timer.wait_time = mouse_click_right_wait_time
	add_child(mouse_click_right_timer)
	

func _process(delta):
	if Input.is_action_pressed("mouse_click_left"):
		if !obstacle_mouse_pressed:
			previous_left_mouse_click_global_position = get_global_mouse_position()
			for character in level_scene.characters:
				character.set_navigation_position(get_global_mouse_position())
	else:
		obstacle_mouse_pressed = false

	if Input.is_action_pressed("mouse_click_right"):
		if mouse_click_right_timer.is_stopped():
			previous_right_mouse_click_global_position = get_global_mouse_position()
			level_scene.call_deferred("create_character")
			mouse_click_right_timer.start()

	if Input.is_action_pressed("mouse_click_middle"):
		move_camera_with_mouse = true
		level_scene.level_camera.set_target_position(get_global_mouse_position())
	else:
		if move_camera_with_mouse:
			move_camera_with_mouse = false
			level_scene.level_camera.set_target_position(level_scene.level_camera.global_position + level_scene.level_camera.global_position.direction_to(get_global_mouse_position()) * mouse_move_drift_weight)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			level_scene.level_camera.zoom_out()
		elif event.button_index == BUTTON_WHEEL_UP:
			level_scene.level_camera.zoom_in()
			
		
		
	if event is InputEventMouseMotion:
		if move_camera_with_mouse:
			level_scene.level_camera.set_target_position(get_global_mouse_position())
