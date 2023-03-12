# Author : Shaun Harbison
# MIT License : 2022

extends Camera2D

var camera_target_position : Vector2
var camera_destination_weight = 0.0
var camera_speed_multiplier = 0.8

func _ready():
	camera_destination_weight = 0.0
	camera_target_position = global_position
	make_current()

func _physics_process(delta : float):
	if camera_destination_weight <= 1.0:
		camera_destination_weight += delta * camera_speed_multiplier
		global_position = global_position.lerp(camera_target_position, camera_destination_weight)
	else:
		pass

func set_target_position(camera_target_position_to_set : Vector2):
	camera_target_position = camera_target_position_to_set
	camera_destination_weight = 0.0

func zoom_in():
	var new_zoom: Vector2 = zoom
	if zoom <= Vector2(5.0, 5.0):
		new_zoom += Vector2(0.1, 0.1)
	new_zoom = new_zoom.clamp(Vector2(0.1, 0.1), Vector2(5.0, 5.0))
	new_zoom = new_zoom.snapped(Vector2(0.1, 0.1))
	set_zoom(new_zoom)
	print("zoom_in = ", zoom)
	
func zoom_out():
	var new_zoom: Vector2 = zoom
	if zoom >= Vector2(0.1, 0.1):
		new_zoom -= Vector2(0.1, 0.1)
	new_zoom = new_zoom.clamp(Vector2(0.1, 0.1), Vector2(5.0, 5.0))
	new_zoom = new_zoom.snapped(Vector2(0.1, 0.1))
	set_zoom(new_zoom)
	print("zoom_out = ", zoom)
