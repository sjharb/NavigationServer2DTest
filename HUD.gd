extends Node2D

var debug_menu : Node2D

func _ready() -> void:
	debug_menu = $DebugMenu

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enable_hud() -> void:
	self.visible = true
	
func set_character_velocity_text(text_to_set : String) -> void:
	debug_menu.get_node("CharacterVelocity").text = text_to_set
