tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

var value : float = 0
var parameter_1 : bool = false
var parameter_2 : bool = false

#internal
var mouse_over : bool = true


#warnings-disable
func _ready() -> void:
	set_process_input(false)
	
	set_meta("value_component", true)
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Wait":
			node_container_base.character_name_preview = true
			node_container_base.set_character_name("0.7") 
			
			$Label.text = "Timeout"
			$SpinBox.value = 0.7
			
			$CheckBox.text = "Wait for input"
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("value"):
			
			value = float(action_node_root.loaded_action_data["value"][0])
			$SpinBox.value = float(action_node_root.loaded_action_data["value"][0])
			set_preview_amount(float(action_node_root.loaded_action_data["value"][0]))
			
			parameter_1 = action_node_root.loaded_action_data["value"][1]
			$CheckBox.pressed = action_node_root.loaded_action_data["value"][1]
			
			parameter_2 = action_node_root.loaded_action_data["value"][2]
			$CheckBox2.pressed = action_node_root.loaded_action_data["value"][2]
	



# Main Action Info
func get_action_data() -> Array:
	return [value, parameter_1, parameter_2]



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !mouse_over && event.pressed:
			mouse_over = true
			$SpinBox.release_focus()
			set_process_input(false)
	elif event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER):
			mouse_over = true
			$SpinBox.release_focus()
			set_process_input(false)




func set_preview_amount(amount:float) -> void:
	var num : float = amount
	
	if num <= 1.0:
		if num == int(num):
			node_container_base.set_character_name(str(amount,".0 second"))
		else:
			node_container_base.set_character_name(str(amount," second"))
	else:
		if num == int(num):
			node_container_base.set_character_name(str(amount,".0 seconds"))
		else:
			node_container_base.set_character_name(str(amount," seconds"))




func _on_SpinBox_changed() -> void:
	value = float($SpinBox.value)
	set_preview_amount($SpinBox.value)


func _on_SpinBox_value_changed(new_value: float) -> void:
	value = new_value
	set_preview_amount(new_value)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	parameter_1 = button_pressed


func _on_CheckBox2_toggled(button_pressed: bool) -> void:
	parameter_2 = button_pressed







func _on_SpinBox_focus_entered() -> void:
	set_process_input(true)


func _on_SpinBox_mouse_entered() -> void:
	mouse_over = true


func _on_SpinBox_mouse_exited() -> void:
	mouse_over = false
