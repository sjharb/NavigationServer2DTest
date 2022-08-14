# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var app_version = "1.0.0"

var level_scene : Node2D
var hud : Node2D

func _ready():
	
	hud = $HUDCanvasLayer/HUD
	hud.enable_hud()
	hud.set_version_hud(app_version)
	level_scene = $Level
	level_scene.init(self)

func _process(delta):
	if Input.is_action_pressed("mouse_click_left"):
		level_scene.mouse_left_press()
	else:
		#TODO do not call every process!
		level_scene.mouse_left_release()

	if Input.is_action_pressed("mouse_click_right"):
		level_scene.mouse_right_press()
	else:
		#TODO do not call every process!
		level_scene.mouse_right_release()

	if Input.is_action_pressed("mouse_click_middle"):
		level_scene.mouse_middle_press()
	else:
		#TODO do not call every process!
		level_scene.mouse_middle_release()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			level_scene.mouse_middle_wheel_down()
		elif event.button_index == BUTTON_WHEEL_UP:
			level_scene.mouse_middle_wheel_up()
	elif event is InputEventMouseMotion:
		level_scene.mouse_motion()
	
