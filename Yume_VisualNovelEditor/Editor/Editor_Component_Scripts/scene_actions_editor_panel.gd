tool
extends PanelContainer

var actions_converter : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_Component_Scripts/actions_file_converter.gd")

export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var scene_actions_container_path : NodePath
var scene_actions_container : Object

export(NodePath) var project_tag_path : NodePath
var project_tag : Object

var CADM : Object


# internal variables:
var open_scene_info : Dictionary = {} setget set_open_scene_info

var keep_flag : bool = false




#warnings-disable
func _ready() -> void:
	_setup_ui()
	
	CADM = scene_actions_container.get_node("CharacterActionsDataManager")


func _setup_ui() -> void:
	get_object_ref(editor_root_path, "editor_root")
	
	get_object_ref(scene_actions_container_path, "scene_actions_container")
	
	get_object_ref(project_tag_path, "project_tag")


func update_open_scene_info(info:Dictionary) -> void:
	open_scene_info = info


func set_open_scene_info(info:Dictionary) -> void:
	open_scene_info = info
	
	# Setup blank action node stack
	if info["scene_script_filepath"] == "":
		_clear_action_nodes()
	else:
		_gen_action_nodes(info["scene_script_filepath"])



func update_scene_info(info:Dictionary) -> void:
	open_scene_info = info


func _gen_action_nodes(filepath:String) -> void:
	_clear_action_nodes()
	_populate_scene_actions(filepath)
	CADM.build_data_lists()



func save() -> void:
	_write_file()



func _write_file(clear:bool = false) -> void:
	if scene_actions_container.vbox.get_child_count() > 0:
		var data_array : Array = []
		
		for i in scene_actions_container.vbox.get_children():
			if i.has_method("get_action_data"):
				data_array.append(i.get_action_data())
		
		var file_paths : Array = actions_converter.export_to_files(editor_root.editor_root.project_directory, open_scene_info, data_array)
		
#		print(file_paths)
		
		# Update open scene path
		var story_tree : Object = editor_root.story_tree
		var current_open : TreeItem = story_tree.current_opened
		
		if current_open:
			current_open.set_meta("script_file", file_paths[1])
			current_open.set_tooltip(1, file_paths[1])
		
		var info : Dictionary = {
			"chapter_number" : open_scene_info["chapter_number"],
			"chapter_title" : open_scene_info["chapter_title"],
			"scene_number" : open_scene_info["scene_number"],
			"scene_name" : open_scene_info["scene_name"],
			"tree_item" : open_scene_info["tree_item"],
			"scene_script_filepath" : file_paths[1]
		}
		
		update_open_scene_info(info)
		
		if clear:
#			print("info cleared")
			
			editor_root.clear_info()
	else:
		var story_tree : Object = editor_root.story_tree
		var current_open : TreeItem = story_tree.current_opened
		
		if current_open:
			current_open.set_meta("script_file", "")
			current_open.set_tooltip(1, "")
		
		if open_scene_info:
			var file_array : Array = actions_converter.export_to_files(editor_root.editor_root.project_directory, open_scene_info, [])
		
		editor_root.clear_info()



func _populate_scene_actions(filepath:String) -> void:
	var action_file : File = File.new()
	
	var parsed_lines_array : Array = []
	
	if action_file.file_exists(filepath):
		
		action_file.open(filepath, File.READ)
		
		while !action_file.eof_reached():
			var current_line : String = action_file.get_line()
			
			var line : Dictionary
			
			if current_line:
				if typeof(parse_json(current_line)) == TYPE_DICTIONARY:
					line = parse_json(current_line)
					parsed_lines_array.append(line)
		
		action_file.close()
	
	
	for i in parsed_lines_array.size():
		var category_info : Dictionary = editor_root.action_list_data[ parsed_lines_array[i]["category"] ]
		var action_info : Dictionary = editor_root.action_list_data[ parsed_lines_array[i]["category"] ]["actions"][parsed_lines_array[i]["name"]]
		
		var action_node : Object = load(action_info["script"]).new()
		
		
		# Setup Action Node Settings
		action_node.action_title = parsed_lines_array[i]["name"]
		
		action_node.action_description = parsed_lines_array[i]["description"]
		
		action_node.action_color_theme = category_info["color_theme"]
		
		action_node.action_icon = load(action_info["icon"])
		
		action_node.action_category = parsed_lines_array[i]["category"]
		
		# Setup loaded data
		action_node.loaded_action_data = parsed_lines_array[i]["action_tag_values"]
		
		
		# Add Action Nodes To Scene
		scene_actions_container.vbox.add_child(action_node)
		
		scene_actions_container._vbox_resized(false, false, true)







func _clear_action_nodes() -> void:
	if !keep_flag:
		for i in scene_actions_container.vbox.get_children():
			if i != scene_actions_container.drop_separator_node:
				i.queue_free()
			else:
				scene_actions_container.drop_separator_node.get_parent().remove_child(scene_actions_container.drop_separator_node)
	else:
		keep_flag = false



func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
