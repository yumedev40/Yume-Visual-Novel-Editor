tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

onready var choose_file_button : Object = $"Button"
onready var choose_file_dialogue : Object = $"FileDialog"

onready var line_edit : Object = $LineEdit
#onready var image_thumbnail : Object = $ImageThumbnail

var mouse_over : bool = true

var image : String = ""




#warnings-disable
func _ready() -> void:
	set_meta("image_component", true)
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Fade Screen":
			hide() ## Temporarily hide component until functionality is added
			$Label.text = "Transition Matte Image"
		"Modulate Scene Color":
			hide() ## Temporarily hide component until functionality is added
			$Label.text = "Mask"
		"Backdrop":
			node_container_base.character_name_preview = true
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("image"):
			line_edit.text = action_node_root.loaded_action_data["image"][0]
			file_check(action_node_root.loaded_action_data["image"][0])



# Main Action Info
func get_action_data() -> Array:
	return [image]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !mouse_over:
			line_edit.release_focus()
			
			if line_edit.is_connected("mouse_entered", self, "_mouse_entered"):
				line_edit.disconnect("mouse_entered", self, "_mouse_entered")
			if line_edit.is_connected("mouse_exited", self, "_mouse_exited"):
				line_edit.disconnect("mouse_exited", self, "_mouse_exited")
			
			mouse_over = true
			
			set_process_input(false)


func _mouse_entered() -> void:
	mouse_over = true


func _mouse_exited() -> void:
	mouse_over = false



func _on_LineEdit_text_entered(new_text: String) -> void:
	line_edit.release_focus()
	
	if line_edit.is_connected("mouse_entered", self, "_mouse_entered"):
		line_edit.disconnect("mouse_entered", self, "_mouse_entered")
	if line_edit.is_connected("mouse_exited", self, "_mouse_exited"):
		line_edit.disconnect("mouse_exited", self, "_mouse_exited")
	
	mouse_over = true
	
	set_process_input(false)
	
	file_check(new_text)


func _on_LineEdit_focus_entered() -> void:
	if !line_edit.is_connected("mouse_entered", self, "_mouse_entered"):
		line_edit.connect("mouse_entered", self, "_mouse_entered")
	if !line_edit.is_connected("mouse_exited", self, "_mouse_exited"):
		line_edit.connect("mouse_exited", self, "_mouse_exited")
	
	set_process_input(true)


func _on_LineEdit_text_changed(new_text: String) -> void:
	file_check(new_text)


func file_check(new_text:String) -> void:
	var file_checker : File = File.new()
	
	if file_checker.file_exists(new_text):
#		var image_data : StreamTexture = load(new_text)
#		var image_thumb : Image = Image.new()
#
#
#		if image_data.get_height() > 40:
#			if image_data.get_width() > 0.0:
#
#				var ratio : float = float(image_data.get_data().get_height())/float(image_data.get_data().get_width())
#				var height : float = float(image_data.get_data().get_height())/ float(40.0)
#
#				image_thumb.copy_from(image_data.get_data())
#				image_thumb.resize(height/ratio, height)
#
#				var dir : String = str(action_node_root.get_parent().get_parent().editor_root.editor_root.editor_root.project_directory)
#
#				var path_decomp : Array = new_text.split("/")
#				var path_base : String = path_decomp[path_decomp.size() - 1]
#				path_decomp = path_base.split(".")
#
#				var file_name : String = path_decomp[0]
#
#				var filepath : String = str(dir, "/_thumbs_/", file_name, "_thumbnail", ".png")
#
#				print(file_name)
#
#			image_saver.save()
#		
#		var image_texture : ImageTexture = ImageTexture.new()
#		image_texture.create_from_image(image_data)
		
#		image_thumbnail.texture = image_data
		
		
		image = new_text
		
		line_edit.set("custom_colors/font_color", Color.green)
		
		line_edit.hint_tooltip = new_text
		
		for i in get_parent().get_children():
			if i.has_meta("transition_settings"):
				i.get_node("VBoxContainer2/HBoxContainer2/PanelContainer/ColorRect").set_image(load(new_text))
		
		match action_node_root.action_title:
			"Backdrop":
				node_container_base.set_character_name(new_text.get_file().split(".")[0])
	else:
#		image_thumbnail.texture = null
#		push_error(str("Image filepath is not a valid file > ", new_text))
		line_edit.set("custom_colors/font_color", Color.red)
		
		for i in get_parent().get_children():
			if i.has_meta("transition_settings"):
				i.get_node("VBoxContainer2/HBoxContainer2/PanelContainer/ColorRect").set_image(null)
		
		match action_node_root.action_title:
			"Backdrop":
				node_container_base.set_character_name("")


func _on_Button_pressed() -> void:
	choose_file_dialogue.popup_centered(Vector2(700,500))


func _on_FileDialog_file_selected(path: String) -> void:
	line_edit.text = path
	file_check(path)
