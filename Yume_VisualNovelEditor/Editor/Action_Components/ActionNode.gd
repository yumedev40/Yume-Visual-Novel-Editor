tool
extends Button

var editor_root : Object

var action_title : String = "Action Title"
var action_category : String = "Action Category"
var action_description : String = ""
var action_script : GDScript



#warnings-disable
func _ready() -> void:
	editor_root = $"../../.." 

func set_title(title:String) -> void:
	action_title = title

func set_category(category:String) -> void:
	action_category = category

func set_description(description:String) -> void:
	action_description = description
	get_node("VBoxContainer/HBoxContainer/Label").text = str(action_title)
	hint_tooltip = description

func set_icon(path:String) -> void:
	var file : File = File.new()
	
	if path.replace(" ", "") == "null":
		return
	
	if file.file_exists(path.replace(" ", "")):
		get_node("VBoxContainer/HBoxContainer/TextureRect").texture = load(path.replace(" ", ""))
	else:
		push_error(str(action_title, " - ", "Invalid Icon Path"))

func set_icon_color(color:Color) -> void:
	get_node("VBoxContainer/HBoxContainer/TextureRect").modulate = color

func set_action_script(path:String) -> void:
	var file : File = File.new()
	
	if path.replace(" ", "") == "null":
		return
	
	if file.file_exists(path.replace(" ", "")):
		action_script = load(path.replace(" ", ""))
	else:
		push_error(str(action_title, " - ", "Invalid Script Path"))

func get_action_script() -> GDScript:
	return action_script




func get_drag_data(position:Vector2) -> Object:
	var script : GDScript = GDScript.new()
	script.resource_name = "action_node"
	
	var data_preview : HBoxContainer = HBoxContainer.new()
	
	data_preview.set("custom_constants/separation", 10)
	
	var data_thumbnail : TextureRect = TextureRect.new()
	
	var node_icon : Object = $"VBoxContainer/HBoxContainer/TextureRect"
	
	data_thumbnail.texture = node_icon.texture
	
	data_thumbnail.modulate = Color(node_icon.modulate.r, node_icon.modulate.g, node_icon.modulate.b, 0.5)
	
	var data_label : Label = Label.new()
	data_label.text = action_title
	
	data_preview.add_child(data_thumbnail)
	data_preview.add_child(data_label)
	
	set_drag_preview(data_preview)
	
	
	var action_script : GDScript = get_action_script()
	
	if action_script:
		action_script.set_meta("action_node", "action")
		action_script.set_meta("action_title", data_label.text)
		action_script.set_meta("action_description", action_description)
		action_script.set_meta("action_color_theme", data_thumbnail.modulate)
		action_script.set_meta("action_icon", data_thumbnail.texture)
		
		action_script.set_meta("action_category", action_category)
#		action_script.set_meta("action_name", action_title)
	else:
		action_script = GDScript.new()
		data_label.text = "Script Missing"
	
	return action_script
