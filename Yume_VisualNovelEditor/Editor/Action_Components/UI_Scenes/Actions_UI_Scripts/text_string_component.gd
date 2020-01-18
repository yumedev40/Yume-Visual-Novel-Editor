tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

# internal
var mouse_over: bool = true

var text_string : String = ""


#warnings-disable
func _ready() -> void:
	set_meta("text_string_component", true)
	
	# preview initialization
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Expressed Line":
			$VBoxContainer/HBoxContainer/Label.text = "Speaker Name"
			node_container_base.character_name_preview = true
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("text_string"):
			text_string = action_node_root.loaded_action_data["text_string"][0]
			$VBoxContainer/HBoxContainer/LineEdit.text = action_node_root.loaded_action_data["text_string"][0]
			node_container_base.set_character_name(action_node_root.loaded_action_data["text_string"][0])



# Main Action Info
func get_action_data() -> Array:
	return [text_string]



func _on_LineEdit_text_changed(new_text: String) -> void:
	text_string = new_text
	node_container_base.set_character_name(new_text)

func _on_LineEdit_text_entered(new_text: String) -> void:
	text_string = new_text
	node_container_base.set_character_name(new_text)






func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed && !mouse_over:
			$VBoxContainer/HBoxContainer/LineEdit.release_focus()
			mouse_over = true
			set_process(false)
	elif event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER):
			$VBoxContainer/HBoxContainer/LineEdit.release_focus()
			mouse_over = true
			set_process(false)

func _on_LineEdit_focus_entered() -> void:
	set_process_input(true)

func _on_LineEdit_mouse_entered() -> void:
	mouse_over = true

func _on_LineEdit_mouse_exited() -> void:
	mouse_over = false
