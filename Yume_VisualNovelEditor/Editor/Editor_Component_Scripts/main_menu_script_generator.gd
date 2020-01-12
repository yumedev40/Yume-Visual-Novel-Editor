extends Node




#warnings-disable
func _ready() -> void:
	pass

func generate_menu_script(node:Object) -> GDScript:
	# Get a list of all the object's child nodes
	var node_list : Array = _filter_array(_get_object_child_nodes(node))
	var button_list : Array = []
	var button_path_list : PoolStringArray = []
	
	# Find any buttons in node_list and add them to button_list array
	for i in node_list.size():
		if node_list[i] is BaseButton:
			button_list.append(node_list[i])
	
	for i in button_list.size():
		var button_paths : Array = _filter_array(_return_nodepath(button_list[i], node))
		button_paths.invert()
		
		var button_node_path : String = _convert_array_to_string(button_paths)
		
		button_path_list.append(str(button_node_path, "/", button_list[i].name))
	
	# Generate script text
	var line_1 : String = "extends Node\n\n"
	var line_2 : String = ""
	var line_3 : String = "\n\n#warnings-disable\nfunc _ready() -> void:\n"
	var line_4 : String = ""
	var line_5 : String = ""
	
	for i in button_list.size():
		match button_list[i].name:
			"Begin":
				line_2 += str("onready var _begin : Button = $'", button_path_list[i], "'\n")
				line_4 += "\t_begin.connect('pressed', self, '_on_Begin_pressed')\n"
				line_5 += "\nfunc _on_Begin_pressed() -> void:\n\tprint('Begin pressed.')\n"
			"Continue":
				line_2 += str("onready var _continue : Button = $'", button_path_list[i], "'\n")
				line_4 += "\t_continue.connect('pressed', self, '_on_Continue_pressed')\n"
				line_5 += "\nfunc _on_Continue_pressed() -> void:\n\tprint('Continue pressed.')\n"
			"Load":
				line_2 += str("onready var _load : Button = $'", button_path_list[i], "'\n")
				line_4 += "\t_load.connect('pressed', self, '_on_Load_pressed')\n"
				line_5 += "\nfunc _on_Load_pressed() -> void:\n\tprint('Load pressed.')\n"
			"Settings":
				line_2 += str("onready var _settings : Button = $'", button_path_list[i], "'\n")
				line_4 += "\t_settings.connect('pressed', self, '_on_Settings_pressed')\n"
				line_5 += "\nfunc _on_Settings_pressed() -> void:\n\tprint('Settings pressed.')\n"
			"Exit":
				line_2 += str("onready var _exit : Button = $'", button_path_list[i], "'\n")
				line_4 += "\t_exit.connect('pressed', self, '_on_Exit_pressed')\n"
				line_5 += "\nfunc _on_Exit_pressed() -> void:\n\tprint('Exit pressed.')\n"
	
	var menu_script : GDScript = GDScript.new()
	menu_script.source_code = str(line_1, line_2, line_3, line_4, line_5, "\n")
	
	return menu_script





# Helper Methods

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )


func _get_object_child_nodes(object:Object) -> Array:
	# Recursively populate an array with all the child nodes of the specified object
	var child_object_array : Array = []
	child_object_array.append(object.get_children())
	
	if object.get_children().size() > 0:
		for i in object.get_children():
			child_object_array += _get_object_child_nodes(i)
	
	return child_object_array


func _filter_array(array:Array) -> Array:
	# Unconcatenate arrays and remove empty arrays
	var base_array : Array = array.duplicate(true)
	var new_array : Array = []
	
	for i in base_array.size():
		if base_array[i] is Array:
			if base_array[i].size() > 0:
				for x in base_array[i].size():
					new_array.append(base_array[i][x])
		else:
			new_array.append(base_array[i])
	
	return new_array


func _return_nodepath(object:Object, root:Object) -> Array:
	var node_list : Array = []
	var parent : Object = object.get_parent()
	
	if parent:
		if parent != root && object != root:
			node_list.append(parent.name)
			node_list += _return_nodepath(parent, root)
	
	return node_list


func _convert_array_to_string(array:Array) -> String:
	var string : String = ""
	
	for i in array.size():
		if i == 0:
			string += array[i]
		else:
			string += str("/", array[i])
	
	return string

