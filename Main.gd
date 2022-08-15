# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var app_version = "1.0.0"

var level_scene : Node2D
var hud : Node2D

# mouse click does not have a release action, keep track manually
var mouse_left_pressed = false
var mouse_right_pressed = false
var mouse_middle_pressed = false

func _ready():
	hud = $HUDCanvasLayer/HUD
	hud.enable_hud()
	hud.set_version_hud(app_version)
	level_scene = $Level
	level_scene.init(self)

func _process(delta):
	if Input.is_action_pressed("mouse_click_left"):
		mouse_left_pressed = true
		level_scene.mouse_left_press()
	else:
		if mouse_left_pressed:
			level_scene.mouse_left_release()
			mouse_left_pressed = false

	if Input.is_action_pressed("mouse_click_right"):
		mouse_right_pressed = true
		level_scene.mouse_right_press()
	else:
		if mouse_right_pressed:
			level_scene.mouse_right_release()
			mouse_right_pressed = false

	if Input.is_action_pressed("mouse_click_middle"):
		mouse_middle_pressed = true
		level_scene.mouse_middle_press()
	else:
		if mouse_middle_pressed:
			level_scene.mouse_middle_release()
			mouse_middle_pressed = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			level_scene.mouse_middle_wheel_down()
		elif event.button_index == BUTTON_WHEEL_UP:
			level_scene.mouse_middle_wheel_up()
	elif event is InputEventMouseMotion:
		level_scene.mouse_motion()
	
