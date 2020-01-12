tool
extends VBoxContainer

export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var hide_toggle_button_path: NodePath
var hide_toggle_button: Object

var collapse_icon : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/collapse_menu.png")

var expand_icon : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/expand_menu.png")

var node_container : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Action_Components/UI_Scenes/node_category_template.tscn")

var action_node : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Action_Components/UI_Scenes/action_node_template.tscn")



#warnings-disable
func _ready() -> void:
	get_object_ref(hide_toggle_button_path, "hide_toggle_button")
	
	get_object_ref(editor_root_path, "editor_root")
	
	_parse_action_data()


func _parse_action_data() -> void:
	for i in get_children():
		i.queue_free()
	
	var data_file : File = File.new()
	var data_path : String = "res://addons/Yume_VisualNovelEditor/Editor/Action_Components/ActionTreeData.DATA"
	
	if data_file.file_exists(data_path):
		var tree_data_array : PoolStringArray = []

		data_file.open(data_path, File.READ)
		
		while !data_file.eof_reached():
			tree_data_array.append(data_file.get_line())
		
		data_file.close()
		
		_parse_action_tree_data(tree_data_array)
		
	else:
		push_error("WARNING: ACTION TREE DATA FILE MISSING OR UNREADABLE")


func _parse_action_tree_data(data_array:PoolStringArray) -> void:
	var category_node_objects : Array = []
	var current_category : Object
	var current_category_name : String
	var action : Object
	var action_name : String
	
	# Parser State:
		# 0 - Searching for Categories, Default
		# 1 - Searching for Category Description
		# 2 - Searching for Category Color Theme
		# 3 - Searching for Actions
		# 4 - Searching for Action Description
		# 5 - Searching for Action Icon
		# 6 - Searching for Action Script
	var parser_state : int = 0
	
	for i in data_array:
		var current_line : String = i
		current_line = current_line.replace("[", " ").replace("]", " ")
		
		var parse_array : PoolStringArray = current_line.split(": ")
		if parse_array.size() > 1:
			
			parse_array[0] = parse_array[0].replace(" ", "")
			
			match parser_state:
				1:
					if parse_array[0] == "description":
						current_category.set_description(parse_array[1])
						editor_root.action_list_data[current_category_name]["description"] = parse_array[1]
						parser_state = 2
					else:
						push_error(str(current_category.get_title(), " -- Action Node Category Data is missing a description -- SKIPPING"))
						
						parser_state = 0
				2:
					if parse_array[0] == "color_theme":
						var color_string : String = parse_array[1].replace("(", "").replace(")", "")
						var char_array : Array = color_string.split(",")  
						var color_vector : Vector3 = Vector3( int(char_array[0]), int(char_array[1]), int(char_array[2]) )
						
						var color_theme : Color = Color8(color_vector.x, color_vector.y, color_vector.z)
						
						current_category.set_color_theme(color_theme)
						editor_root.action_list_data[current_category_name]["color_theme"] = color_theme
					else:
						push_error(str(current_category.get_title, " -- Action Node Category Data is missing a Color Theme -- SKIPPING"))
					
					parser_state = 3
				3:
					if parse_array[0] == "action":
						action = action_node.instance()
						action.set_title(parse_array[1])
						action.set_category(current_category_name)
						
						current_category.get_node("ActionList/NodeContainer").add_child(action)
						
						if parse_array[1].ends_with(" "):
							action_name = parse_array[1].left(parse_array[1].length() - 1)
						else:
							action_name = parse_array[1]
						
						editor_root.action_list_data[current_category_name]["actions"][action_name] = {}
						
						parser_state = 4
				4:
					if parse_array[0] == "description":
						action.set_description(parse_array[1])
						editor_root.action_list_data[current_category_name]["actions"][action_name]["description"] = parse_array[1]
						
						parser_state = 5
				5:
					if parse_array[0] == "icon":
						action.set_icon(parse_array[1])
						action.set_icon_color(current_category.get_color_theme())
						
						if parse_array[1].ends_with(" "):
							editor_root.action_list_data[current_category_name]["actions"][action_name]["icon"] = parse_array[1].left(parse_array[1].length() - 1)
						else:
							editor_root.action_list_data[current_category_name]["actions"][action_name]["icon"] = parse_array[1]
						
						parser_state = 6
				6:
					if parse_array[0] == "script":
						action.set_action_script(parse_array[1])
						
						if parse_array[1].ends_with(" "):
							editor_root.action_list_data[current_category_name]["actions"][action_name]["script"] = parse_array[1].left(parse_array[1].length() - 1)
						else:
							editor_root.action_list_data[current_category_name]["actions"][action_name]["script"] = parse_array[1]
						
						parser_state = 3
			
			
			if parse_array[0] == "category":
				if current_category:
					current_category = node_container.instance()
					if !category_node_objects.has(current_category):
						category_node_objects.append(current_category)
				
				if !current_category:
					current_category = node_container.instance()
					if !category_node_objects.has(current_category):
						category_node_objects.append(current_category)
				
				if parse_array[1] != "":
					current_category.set_title(parse_array[1])
				
				# Remove any empty spaces at the end of category names
				if parse_array[1].ends_with(" "):
					current_category_name = parse_array[1].left(parse_array[1].length() - 1)
				else:
					current_category_name = parse_array[1]
				
				editor_root.action_list_data[current_category_name] = {
					"description" : "",
					"color_theme" : Color.white,
					"actions" : {}
				}
				
				parser_state = 1
	
	if category_node_objects.size() > 0:
		for i in category_node_objects:
			add_child(i)




# Helper Methods

func _on_MenuFoldButtons_toggled(button_pressed: bool) -> void:
	if button_pressed:
		for i in get_children():
			if i.has_method("_on_hide_button_pressed"):
				i.hide_button.pressed = true
				i._on_hide_button_pressed()

		if !hide_toggle_button.pressed:
			hide_toggle_button.pressed = true

		hide_toggle_button.set("texture_normal", expand_icon)
	else:
		for i in get_children():
			if i.has_method("_on_hide_button_pressed"):
				i.hide_button.pressed = false
				i._on_hide_button_pressed()

		if hide_toggle_button.pressed:
			hide_toggle_button.pressed = false

		hide_toggle_button.set("texture_normal", collapse_icon)

	pass


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )


