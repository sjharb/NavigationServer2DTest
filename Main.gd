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
			#print("Mouse : ", event.global_position)
			#print("Mouse : ", level_scene.level_camera.global_position)
			print("Mouse : ", get_global_mouse_position())
			#print("Mouse : ", get_global_transform())
			#print("Mouse : ", get_global_transform_with_canvas())
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
		#print("move_camera_with_mouse = ", move_camera_with_mouse)
		level_scene.level_camera.set_target_position(get_global_mouse_position())
	else:
		if move_camera_with_mouse:
			move_camera_with_mouse = false
			#print("move_camera_with_mouse = ", move_camera_with_mouse)
			#level_scene.level_camera.set_target_position(get_global_mouse_position())
			level_scene.level_camera.set_target_position(level_scene.level_camera.global_position + level_scene.level_camera.global_position.direction_to(get_global_mouse_position()) * mouse_move_drift_weight)

#	if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
#		level_scene.level_camera.zoom_out()
#	elif Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
#		level_scene.level_camera.zoom_in()

	#if Input.is_mouse_button_pressed()


func _unhandled_input(event):
#func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
#		if event.pressed:
#			if event.button_index == BUTTON_LEFT:
#				previous_left_mouse_click_global_position = get_global_mouse_position()
#				#print("Mouse Click/Unclick at: ", event.global_position)
#				#print("Mouse Click/Unclick at: ", level_scene.level_camera.global_position)
#				print("Mouse Click/Unclick at: ", get_global_mouse_position())
#				#print("Mouse Click/Unclick at: ", get_global_transform())
#				#print("Mouse Click/Unclick at: ", get_global_transform_with_canvas())
#				for character in level_scene.characters:
#
#					character.set_navigation_position(get_global_mouse_position())
#			elif event.button_index == BUTTON_RIGHT:
#				previous_right_mouse_click_global_position = get_global_mouse_position()
#				level_scene.call_deferred("create_character")
#			elif event.button_index == BUTTON_MIDDLE:
#				move_camera_with_mouse = true
#				print("move_camera_with_mouse = ", move_camera_with_mouse)
#				level_scene.level_camera.set_target_position(get_global_mouse_position())
#		elif event.button_index == BUTTON_MIDDLE:
#			move_camera_with_mouse = false
#			print("move_camera_with_mouse = ", move_camera_with_mouse)
#			level_scene.level_camera.set_target_position(get_global_mouse_position())
		if event.button_index == BUTTON_WHEEL_DOWN:
			level_scene.level_camera.zoom_out()
		elif event.button_index == BUTTON_WHEEL_UP:
			level_scene.level_camera.zoom_in()
			
		
		
	if event is InputEventMouseMotion:
		if move_camera_with_mouse:
			level_scene.level_camera.set_target_position(get_global_mouse_position())
#		if level_scene.obstacle_movable.obstacle_movable_mouse_pressed:
#			previous_left_mouse_click_global_position = get_global_mouse_position()
#			#print("Mouse Click/Unclick at: ", event.global_position)
#			#print("Mouse Click/Unclick at: ", level_scene.level_camera.global_position)
#			print("Mouse Move: ", get_global_mouse_position())
#			#print("Mouse Click/Unclick at: ", get_global_transform())
#			#print("Mouse Click/Unclick at: ", get_global_transform_with_canvas())
#			for character in level_scene.characters:
#				character.set_navigation_position(get_global_mouse_position())
		#print("get_global_transform_with_canvas().get_origin() = ", get_global_transform_with_canvas().get_origin())
		#if get_global_transform_with_canvas().get_origin() > Vector2(200, 200):
		#level_scene.level_camera.set_target_position(get_global_mouse_position())
	   #print("Mouse Motion at: ", event.position)
	# Print the size of the viewport.
	#print("Viewport Resolution is: ", get_viewport_rect().size)