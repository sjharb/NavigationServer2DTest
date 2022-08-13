extends KinematicBody2D

var nav_agent : NavigationAgent2D
var velocity : Vector2

var nav_optimize_path = false

var nav_destination : Vector2

var character_speed_multiplier : float = 50.0

var character_nav_path = []
var character_real_nav_path = []

var next_nav_position : Vector2

var level_scene : Node2D

func _ready():
	#level_scene = get_parent()
	velocity = Vector2(0,0)
	nav_destination = self.global_position
	next_nav_position = self.global_position
	nav_agent = $NavigationAgent2D
	nav_agent.connect("path_changed", self, "character_path_changed")
	nav_agent.connect("target_reached", self, "character_target_reached_reached")
	nav_agent.connect("navigation_finished", self, "character_navigation_finished")
	nav_agent.connect("velocity_computed", self, "character_velocity_computed")
	nav_agent.max_speed = character_speed_multiplier
	nav_agent.radius = 15.0
	nav_agent.avoidance_enabled = true
	nav_agent.set_target_location(nav_destination)
	
	#level_scene.characters.push_back(self)

func init_character(parent_level_scene, instanced_in_code : bool):
	level_scene = parent_level_scene
	if instanced_in_code:
		self.global_position = level_scene.main.previous_right_mouse_click_global_position
		set_navigation_position(level_scene.main.previous_left_mouse_click_global_position)

func _process(delta):
	update()

#func _draw():
#	draw_rect(Rect2(1280/2, 720/2, 1280, 720), Color(0.0, 1.0, 1.0, 1.0), 3.0, false)
#	var previous_line_point = self.global_position
#	for line_point in self.character_nav_path:
#		draw_line(previous_line_point, line_point, Color(0.0, 0.0, 1.0, 1.0), 3.0, false)
#		previous_line_point = line_point
		
	#draw_circle(self.next_nav_position, 10.0, Color(0.0, 1.0, 0.0, 1.0))
	
	#draw_circle(self.global_position, self.nav_agent.radius, Color(1.0, 0.0, 0.0, 1.0))
	
	#draw_circle(self.nav_destination, self.nav_agent.radius, Color(1.0, 0.5, 0.0, 1.0))

func _physics_process(delta : float) -> void:
	#if nav_agent.is_target_reachable() and !nav_agent.is_target_reached():
	#nav_agent.set_velocity(velocity)
	
	next_nav_position = nav_agent.get_next_location()
	character_real_nav_path.push_back(next_nav_position)
	
	#self.global_position = next_nav_position
	
	#velocity = (self.global_position - next_nav_position) * delta * character_speed_multiplier
	velocity = self.global_position.direction_to(next_nav_position) * character_speed_multiplier
	
	#Navigation2DServer.map_get_path(nav_agent.get_rid())
	
	nav_agent.set_velocity(velocity)
	
	#self.move_and_slide(velocity)
	#print("velocity = ", velocity)
	#level_scene.main.hud.get_node("DebugMenu/Character Velocity").text = str(velocity)
	#level_scene.main.hud.set_character_velocity_text(str(velocity))
	#NavigationServer.agent_create()
		
	#self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_rid(), global_position)

func set_navigation_position(nav_position_to_set : Vector2):
	#print("set_navigation_position : nav_position_to_set = ", nav_position_to_set)
	#velocity = self.global_position - nav_position_to_set
	nav_destination = nav_position_to_set
	nav_agent.set_target_location(nav_destination)
	character_nav_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), self.global_position, nav_destination, nav_optimize_path)
	character_real_nav_path.clear()
	#print("character_nav_path = ", character_nav_path)
	#nav_agent.set_velocity(velocity)

func character_path_changed():
	#print("character_path_changed")
	pass
	
func character_target_reached_reached():
	#print("character_target_reached_reached")
	pass
	
func character_navigation_finished():
	#print("character_navigation_finished")
	pass
	
func character_velocity_computed(new_velocity : Vector2):
	#print("character_velocity_computed : new_velocity = ", new_velocity)
	velocity = new_velocity
	#nav_agent.set_velocity(new_velocity)
	#if nav_agent.is_target_reachable() and !nav_agent.is_target_reached():
	if !nav_agent.is_target_reached():
		self.move_and_slide(velocity)
	else:
		self.global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position)


