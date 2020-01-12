tool
extends HBoxContainer

var ui_base : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Action_Components/UI_Scenes/scene_node_template.tscn")

var action_tag_array : PoolStringArray = []

var loaded_action_data : Dictionary

# internal_vars
var action_title : String = "ActionNode"
var action_category : String = "Category"
var action_description : String
var action_color_theme : Color
var action_icon : StreamTexture


#warnings-disable
func _ready() -> void:
	set_owner(get_parent())
	set("mouse_filter", Control.MOUSE_FILTER_PASS)
	set_meta("_scene_node_", true)
	
	if action_title.ends_with(" "):
		action_title = action_title.left(action_title.length()-1)
	
	if action_category.ends_with(" "):
		action_category = action_category.left(action_category.length()-1)
	
#	print(str(action_category," Action : ", action_title, " -- added to scene actions list"))



func get_action_data() -> Dictionary:
	var data_dict : Dictionary = {
		"category" : action_category,
		"name" : action_title,
		"description" : action_description,
		"action_tag_values" : {}
	}
	
	var component_container : Object = get_child(0).get_node("HBoxContainer/VBoxContainer/PanelContainer2/UI")
	var current_tag : int = 0
	
	for i in component_container.get_child_count():
		if current_tag > action_tag_array.size() - 1:
			break
		else:
			var component : Object = component_container.get_child(i)
			
			if !component is HSeparator:
				if component.has_method("get_action_data"):
					data_dict["action_tag_values"][str(action_tag_array[current_tag])] = component.get_action_data()
				else:
					push_warning(str("[", action_category, "]"," [ ", action_title," ] [", component.name, "]", " is missing method 'get_action_data', unable to retrieve action data"))
				
				current_tag += 1
	
	return data_dict


func add_action_tag(tag:String) -> void:
	action_tag_array.append(tag)


func build_ui() -> void:
	var new_name : String = gen_random_name( str( action_title, "_", get_parent().get_child_count() + 1 ) )
	
	name = new_name
	
	var ui_container : Object = ui_base.instance()
	var ui_container_vbox : Object = ui_container.get_node("HBoxContainer/VBoxContainer/PanelContainer2/UI")
	
	var ui_builder : Object = load("res://addons/Yume_VisualNovelEditor/Editor/Action_Components/ActionComponentPaths.gd").new()
	
	for i in action_tag_array:
		var ui_component : Object = load(str(ui_builder.get(i))).instance()
		ui_container_vbox.add_child(ui_component)
		
		# Handle UI initial setup
		if "default_text" in ui_component:
			ui_component.set_meta("set_default_text", ui_component.default_text)
		
		# Add separator between tag ui elements
		if i != action_tag_array[action_tag_array.size()-1]:
			var separator : Object = HSeparator.new()
			separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			ui_container_vbox.add_child(separator)
	
	ui_builder.queue_free()
	
	add_child(ui_container)


# Helper methods
func gen_random_name(old_name:String) -> String:
	var flag : bool = false
	for i in get_parent().get_children():
		if i.name == old_name:
			flag = true
	
	if flag:
		var new_name : String = name
		new_name = str(new_name, gen_random_id())
		return new_name
	else:
		return old_name


func gen_random_id() -> String:
	var id : String = "@"
	randomize()
	var num : int = randi()%100+1
	
	id = str(id, num)
	
	return id
