extends Camera2D

var camera_target_position : Vector2

var camera_destination_weight = 0.0

var camera_speed_multiplier = 1.0

func _ready():
	camera_destination_weight = 0.0
	camera_target_position = self.global_position
	current = true


func _physics_process(delta):
	#print("camera_destination_weight = ", camera_destination_weight)
	if camera_destination_weight <= 1.0:
		#print("camera_destination_weight = ", camera_destination_weight)
		camera_destination_weight += delta * camera_speed_multiplier
		global_position = global_position.linear_interpolate(camera_target_position, camera_destination_weight)
		#global_position = global_position.cubic_interpolate(camera_target_position, Vector2(0.0, 0.0), Vector2(0.0, 0.0), camera_destination_weight)
		#print("global_position = ", global_position)
	else:
		pass

func set_target_position(camera_target_position_to_set):
	camera_target_position = camera_target_position_to_set
	#print("set_target_position : camera_target_position = ", camera_target_position)
	#print("self.global_position = ", self.global_position)
	camera_destination_weight = 0.0

func zoom_out():
	if zoom <= Vector2(5.0, 5.0):
		zoom += Vector2(0.1, 0.1)
	
func zoom_in():
	if zoom >= Vector2(0.1, 0.1):
		zoom -= Vector2(0.1, 0.1)
