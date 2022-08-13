extends Node2D

#var obstacle_mouse_pressed = false
var obstacle_area
var collision_radius : float = 20.0

var nav_agent : NavigationAgent2D

var level_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	obstacle_area = $Area2D
	obstacle_area.connect("input_event", self, "_on_area_input_event")
	obstacle_area.get_node("CollisionShape2D").shape.radius = collision_radius
	nav_agent = $NavAgent

func init_obstacle(parent_level_scene):
	level_scene = parent_level_scene

func _process(delta):
	if level_scene.main.obstacle_mouse_pressed:
		#self.global_position = get_global_mouse_position()
		self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), get_global_mouse_position())
	#else:
	#	self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), get_global_mouse_position())
#
#func _input(event):
#
#	if event is InputEventMouseButton:
#		if event.pressed:
#			if event.button_index == BUTTON_LEFT:
#				obstacle_mouse_pressed = true
#		else:
#			obstacle_mouse_pressed = false

func _on_area_input_event(event_viewport : Node, event : InputEvent, event_shape_index : int):
	print("event : InputEvent = ", event)
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				level_scene.main.obstacle_mouse_pressed = true
		else:
			if level_scene.main.obstacle_mouse_pressed:
				level_scene.main.obstacle_mouse_pressed = false
				#self.global_position = get_global_mouse_position()
				self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), get_global_mouse_position())
