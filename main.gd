# Author : Shaun Harbison
# MIT License : 2022

extends Node2D

var app_version : String = "2.1.0"

@onready var level_scene : Node2D = get_node("Level")
@onready var hud : Node2D = get_node("HudCanvasLayer/Hud")

# mouse click does not have a release action, keep track manually
var mouse_left_pressed = false
var mouse_right_pressed = false
var mouse_middle_pressed = false

func _ready() -> void:
	hud.enable_hud()
	hud.set_version_hud(app_version)
	level_scene.call_deferred("init", self)

func _process(_delta : float) -> void:
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

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			level_scene.mouse_middle_wheel_down()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			level_scene.mouse_middle_wheel_up()
	elif event is InputEventMouseMotion:
		level_scene.mouse_motion()
	
