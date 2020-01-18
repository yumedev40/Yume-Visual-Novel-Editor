tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

var flag : bool = false
var extra_param_1 : bool = false
var extra_param_2 : bool = false


#warnings-disable
func _ready() -> void:
	set_meta("toggle_component", true)
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Backdrop":
			$Label.text = "Change Instantly"
		"Dialogue Box Visibility":
			node_container_base.image_preview = true
			
			node_container_base.set_preview_image(load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/eye_closed.png"))
			
			$Label.text = "Dialogue Box Visible"
			
			$ModifierCheckbox.text = "Reset Dialogue Box On Hide"
			$ModifierCheckbox.pressed = true
			$ModifierCheckbox.show()
			extra_param_1 = true
			
			$ModifierCheckbox2.text = "Use Animation"
			$ModifierCheckbox2.pressed = true
#			$ModifierCheckbox2.show()
			extra_param_2 = true
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("toggle"):
			
			if action_node_root.loaded_action_data["toggle"][0]:
				$CheckButton.pressed = true
				flag = true
				
				match action_node_root.action_title:
					"Backdrop":
						for i in get_parent().get_children():
							if i.has_meta("transition_settings"):
								i.hide()
					"Dialogue Box Visibility":
						$ModifierCheckbox.hide()
						
						node_container_base.set_preview_image(load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/eye_open.png"))
			else:
				$CheckButton.pressed = false
				flag = false
				
				match action_node_root.action_title:
					"Dialogue Box Visibility":
						$ModifierCheckbox.show()
						
						node_container_base.set_preview_image(load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/eye_closed.png"))
			
			if action_node_root.loaded_action_data["toggle"][1]:
				$ModifierCheckbox.pressed = true
				extra_param_1 = true
			else:
				$ModifierCheckbox.pressed = false
				extra_param_1 = false
			
			if action_node_root.loaded_action_data["toggle"][2]:
				$ModifierCheckbox2.pressed = true
				extra_param_2 = true
			else:
				$ModifierCheckbox2.pressed = false
				extra_param_2 = false



# Main Action Info
func get_action_data() -> Array:
	return [flag, extra_param_1, extra_param_2]





func _on_CheckButton_toggled(button_pressed: bool) -> void:
	match button_pressed:
		true:
			flag = true
			
			match action_node_root.action_title:
				"Backdrop":
					for i in get_parent().get_children():
						if i.has_meta("transition_settings"):
							i.hide()
				
				"Dialogue Box Visibility":
					$ModifierCheckbox.hide()
					
					node_container_base.set_preview_image(load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/eye_open.png"))
		_:
			flag = false
			
			match action_node_root.action_title:
				"Backdrop":
					for i in get_parent().get_children():
						if i.has_meta("transition_settings"):
							i.show()
				
				"Dialogue Box Visibility":
					$ModifierCheckbox.show()
					
					node_container_base.set_preview_image(load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/eye_closed.png"))



func _on_ModifierCheckbox_toggled(button_pressed: bool) -> void:
	match button_pressed:
		true:
			extra_param_1 = true
		_:
			extra_param_1 = false


func _on_ModifierCheckbox2_toggled(button_pressed: bool) -> void:
	match button_pressed:
		true:
			extra_param_2 = true
		_:
			extra_param_2 = false
