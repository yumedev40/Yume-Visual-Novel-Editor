tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."




#warnings-disable
func _ready() -> void:
	set_meta("additional_animation_settings", true)
	
	# preview initialization
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Adjust Dialogue Box Settings":
			match get_index():
				0:
					$Label.text = "Name Animation Settings"
				1:
					$Label.text = "Dialogue Animation Settings"
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("text_box_component"):
			pass



# Main Action Info
func get_action_data() -> Array:
	return [true]


func _on_Animation_Mode_item_selected(ID: int) -> void:
	match ID:
		# Default:
		0:
			$Speed.hide()
			$OptionButton.hide()
		# Fade
		1:
			$Speed.show()
			$OptionButton.show()
			
		# Instant
		2:
			$Speed.hide()
			$OptionButton.show()
			
		# Typewriter
		3:
			$Speed.show()
			$OptionButton.show()

