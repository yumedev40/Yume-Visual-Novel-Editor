tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

var color : Color = Color.black

var blend : bool = true

var loaded_data : Dictionary = {}



#warnings-disable
func _ready() -> void:
	set_meta("color_picker", true)
	
	# preview initialization
	
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Fade Screen":
			# action preview flags
			node_container_base.ramp_preview = true
			node_container_base.set_preview_ramp()
			node_container_base.flip_preview_ramp()
			
		"Modulate Scene Color":
			# action preview flags
			node_container_base.color_preview = true
			node_container_base.set_preview_color(Color.white)
			
			$ColorPickerButton.color = Color.white
			
			color = Color.white
			
			$CheckBox.hide()
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("color_picker"):
			var color_array : Array = action_node_root.loaded_action_data["color_picker"][0].split_floats(",")
			
			var loaded_color = Color(color_array[0], color_array[1], color_array[2], 1.0)
			
			node_container_base.set_preview_ramp(loaded_color, Color.darkgray)
			
			node_container_base.set_preview_color(loaded_color)
			
			$ColorPickerButton.color = loaded_color
			
			color = loaded_color
			
			blend = bool(action_node_root.loaded_action_data["color_picker"][1])
			
			$CheckBox.pressed =  bool(action_node_root.loaded_action_data["color_picker"][1])



# Main Action Info
func get_action_data() -> Array:
	return [color, blend]



func _on_ColorPickerButton_color_changed(new_color: Color) -> void:
	color = new_color
	
	node_container_base.set_preview_color(new_color)
	node_container_base.set_preview_ramp(new_color)
	
	match action_node_root.action_title:
		"Fade Screen":
			for i in get_parent().get_children():
				if i.has_meta("transition_settings"):
					i.get_node("VBoxContainer2/HBoxContainer2/PanelContainer/ColorRect").set_start = true
					i.get_node("VBoxContainer2/HBoxContainer2/PanelContainer/ColorRect").set_color(new_color)
		"Modulate Scene Color":
			for i in get_parent().get_children():
				if i.has_meta("transition_settings"):
					i.get_node("VBoxContainer2/HBoxContainer2/PanelContainer/ColorRect").set_color(new_color)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	blend = button_pressed
