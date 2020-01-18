tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

# internal
var mouse_over : bool = true


var file_path : String = "" setget set_filepath



#warnings-disable
func _ready() -> void:
	set_process_input(false)
	
	set_meta("scene_component", true)
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"End":
			node_container_base.character_name_preview = true
			node_container_base.set_character_name("") 
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("scene"):
			$LineEdit.text = action_node_root.loaded_action_data["scene"][0]
			self.file_path = action_node_root.loaded_action_data["scene"][0]
			node_container_base.set_character_name(action_node_root.loaded_action_data["scene"][0].get_file()) 



# Main Action Info
func get_action_data() -> Array:
	return [file_path]


func set_filepath(path:String) -> void:
	var file : File = File.new()
	
	if file.file_exists(path):
		file_path = path
		node_container_base.set_character_name(path.get_file())
		
		$LineEdit.set("custom_colors/font_color", Color.green)
	else:
		file_path = ""
		node_container_base.set_character_name("")
		
		$LineEdit.set("custom_colors/font_color", Color.red)


func _on_LineEdit_text_changed(new_text: String) -> void:
	self.file_path = new_text

func _on_LineEdit_text_entered(new_text: String) -> void:
	self.file_path = new_text


func _on_FileDialog_file_selected(path: String) -> void:
	self.file_path = path
	$LineEdit.text = path


func _on_Button_pressed() -> void:
	$FileDialog.popup_centered(Vector2(700,500))











func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !mouse_over && event.pressed:
			mouse_over = true
			$LineEdit.release_focus()
			set_process_input(false)
	elif event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER):
			mouse_over = true
			$LineEdit.release_focus()
			set_process_input(false)


func _on_LineEdit_focus_entered() -> void:
	set_process_input(true)


func _on_LineEdit_mouse_entered() -> void:
	mouse_over = true


func _on_LineEdit_mouse_exited() -> void:
	mouse_over = false

