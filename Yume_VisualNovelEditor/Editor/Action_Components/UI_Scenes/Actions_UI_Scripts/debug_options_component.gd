tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

onready var mode_menu : Object = $MenuButton
onready var breakpoint_toggle : Object = $CheckButton

enum DEBUG {STRING, WARNING, ERROR}

var debug_output_mode : int = DEBUG.STRING setget set_debug_output_mode, get_debug_output_mode

var breakpoint_mode : bool = false setget set_breakpoint_mode, get_breakpoint_mode

signal debug_mode_changed
signal breakpoint_mode_changed



#warnings-disable
func _ready() -> void:
	set_meta("debug_options_component", true)
	
	yield( get_tree().create_timer(0.1), "timeout" )
	
	for i in get_parent().get_children():
		if i.has_meta("debug_message_component"):
			connect("debug_mode_changed", i, "_on_debug_mode_changed")
			connect("breakpoint_mode_changed", i, "_on_breakpoint_mode_changed")
			break
	
	mode_menu.connect("item_selected", self, "_on_item_selected")
	
	breakpoint_toggle.connect("pressed", self, "_on_breakpoint_toggled")
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("debug_options"):
			
			self.set_debug_output_mode(int(action_node_root.loaded_action_data["debug_options"][0]))
			self.set_breakpoint_mode(action_node_root.loaded_action_data["debug_options"][1])
			
			if typeof(int(action_node_root.loaded_action_data["debug_options"][0])) == TYPE_INT:
				mode_menu.select(int(action_node_root.loaded_action_data["debug_options"][0]))
			
			if action_node_root.loaded_action_data["debug_options"][1] == true:
				breakpoint_toggle.pressed = true
			
			_on_breakpoint_toggled()



# Main Action Info
func get_action_data() -> Array:
	return [get_debug_output_mode(), get_breakpoint_mode()]



func set_debug_output_mode(mode:int) -> void:
	debug_output_mode = clamp(mode, 0, 2)
	emit_signal("debug_mode_changed", debug_output_mode)


func get_debug_output_mode() -> int:
	return debug_output_mode


func set_breakpoint_mode(mode:bool) -> void:
	breakpoint_mode = mode


func get_breakpoint_mode() -> bool:
	return breakpoint_mode


func _on_item_selected(id:int) -> void:
	debug_output_mode = id
	emit_signal("debug_mode_changed", debug_output_mode)


func _on_breakpoint_toggled() -> void:
	if breakpoint_toggle.pressed:
		breakpoint_mode = true
		emit_signal("breakpoint_mode_changed", breakpoint_mode)
	else:
		breakpoint_mode = false
		emit_signal("breakpoint_mode_changed", breakpoint_mode)

