tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

var text_string : String = ""


#warnings-disable
func _ready() -> void:
	set_meta("text_string_component", true)
	
	# preview initialization
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Expressed Line":
			$VBoxContainer/HBoxContainer/Label.text = "Speaker Name"
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("text_string_component"):
			pass



# Main Action Info
func get_action_data() -> Array:
	return [true]


