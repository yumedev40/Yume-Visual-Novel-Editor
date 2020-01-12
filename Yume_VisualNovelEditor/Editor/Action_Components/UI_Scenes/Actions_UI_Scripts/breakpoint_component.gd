tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."




#warnings-disable
func _ready() -> void:
	set_meta("breakpoint_component", true)



# Main Action Info
func get_action_data() -> Array:
	return [true]


