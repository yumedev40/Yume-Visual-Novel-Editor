tool
extends Tabs

onready var editor_root : Object = $"../../.."

export(NodePath) var left_panel_v_handle_path : NodePath
export(NodePath) var left_panel_v_handle_a_path : NodePath
export(NodePath) var left_panel_v_handle_b_path : NodePath

export(NodePath) var center_h_handle_path : NodePath
export(NodePath) var center_h_handle_a_path : NodePath
export(NodePath) var center_h_handle_b_path : NodePath

export(NodePath) var main_v_handle_path : NodePath
export(NodePath) var main_v_handle_a_path : NodePath
export(NodePath) var main_v_handle_b_path : NodePath


var left_panel_v_handle : Object
var left_panel_v_handle_a : Object
var left_panel_v_handle_b : Object

var center_h_handle : Object
var center_h_handle_a : Object
var center_h_handle_b : Object

var main_v_handle : Object
var main_v_handle_a : Object
var main_v_handle_b : Object


export(NodePath) var add_chapter_path : NodePath
export(NodePath) var new_scene_path : NodePath

var add_chapter : Object
var new_scene : Object

export(NodePath) var scene_title_path : NodePath
var scene_title : Object

export(NodePath) var story_tree_path : NodePath
var story_tree : Object

export(NodePath) var action_list_path : NodePath
var action_list : Object

export(NodePath) var scene_actions_path : NodePath
var scene_actions : Object

export(NodePath) var scene_actions_editor_panel_path : NodePath
var scene_actions_editor_panel : Object

export(NodePath) var preview_path : NodePath
var preview : Object


# Action Node List Variables
var action_list_data : Dictionary = {}




#warnings-disable
func _ready() -> void:
	_setup_grab_handles()
	_setup_ui()


func _setup() -> void:
	story_tree._setup()
	preview._setup()
	build_story_tree()





func _open_scene(info:Dictionary, rearrange:bool = false) -> void:
	if rearrange:
		scene_actions_editor_panel.keep_flag = true
	
	scene_actions.scene_open = true
	scene_actions_editor_panel.open_scene_info = info
	
	if rearrange:
		scene_actions_editor_panel._write_file()
	
	scene_actions._reset_menu_fold_button()
	preview.preview_scene_button.disabled = false


func _close_scene() -> void:
	scene_actions_editor_panel._write_file(true)
	scene_actions._reset_menu_fold_button()
	
	preview.reset_ui()
	
	scene_actions.vbar.hide()






func clear_info() -> void:
	scene_actions.scene_open = false
	scene_actions_editor_panel.open_scene_info.clear()
	
	for i in scene_actions.vbox.get_children():
		if i != scene_actions.drop_separator_node:
			i.queue_free()
		else:
			scene_actions.drop_separator_node.get_parent().remove_child(scene_actions.drop_separator_node)
	
	scene_actions.vbar.hide()




# Left panel ui
func _on_add_chapter_pressed() -> void:
#	print("New chapter added")
	
	# Create new chapter tree item
	var tree_item : TreeItem = story_tree.create_item(story_tree.get_root())
	
	# Entitle new tree item
	var chapter_count : int = 0
	var chapter_item : TreeItem = story_tree.get_root().get_children()
	
	while is_instance_valid(chapter_item):
		chapter_count += 1
		chapter_item = chapter_item.get_next()
	
	tree_item.set_text(0, str("Chapter ", chapter_count))
	
	# Set chapter tree item title and subtitle columns editable
	tree_item.set_editable(0, false)
	tree_item.set_editable(1, true)
	
	# Add a close button to tree item
	tree_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
	
	# Format tree item
	tree_item.set_expand_right(0, true)
	tree_item.set_expand_right(1, true)
	
	tree_item.set_custom_bg_color(0, story_tree.chapter_heading_bg)
	tree_item.set_custom_bg_color(1, story_tree.chapter_heading_bg)
	
	# Set tree item metadata
	tree_item.set_metadata(0, "chapter_number")
	tree_item.set_metadata(1, "chapter_title")


func _on_new_scene_pressed() -> void:
	var selected : TreeItem = story_tree.get_selected()
	
#	print(str("New Scene Added to ", selected.get_text(0)))
	
	if selected:
		if selected.get_metadata(0) == "chapter_number":
			var scene_item : TreeItem = story_tree.create_item(story_tree.get_selected())
			
			var scene_count : int = 0
			var items : TreeItem = selected.get_children()
			
			while is_instance_valid(items):
				scene_count += 1
				items = items.get_next()
			
			scene_item.set_text(0, str("Scene " , scene_count))
			
			scene_item.set_metadata(0, "scene_number")
			scene_item.set_metadata(1, "scene_title")
			
			scene_item.set_editable(1, true)
			
			scene_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
			
		elif selected.get_metadata(0) == "scene_number":
			var scene_item : TreeItem = story_tree.create_item(story_tree.get_selected().get_parent())
			
			var scene_count : int = 0
			
			if selected.get_parent():
				var items : TreeItem = selected.get_parent().get_children()
			
				while is_instance_valid(items):
					scene_count += 1
					items = items.get_next()
			
			scene_item.set_text(0, str("Scene " , scene_count))
			
			scene_item.set_metadata(0, "scene_number")
			scene_item.set_metadata(1, "scene_title")
			
			scene_item.set_editable(1, true)
			
			scene_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))




# Helper Methods

func build_story_tree() -> void:
	var story_check : TreeItem = story_tree.get_root().get_children()
	
	if !is_instance_valid(story_check):
		if editor_root.story_data.keys().size() > 0:
			for i in editor_root.story_data["chapters"].keys().size():
				var story_chapter_item : TreeItem = story_tree.create_item(story_tree.get_root())
				
				# SETUP CHAPTER ITEM
				var chapter_number : String = editor_root.story_data["chapters"].keys()[i]
				
				story_chapter_item.set_text(0, chapter_number)
				
				story_chapter_item.set_text(1, editor_root.story_data["chapters"][chapter_number]["title"])
				
				# Set chapter tree item title and subtitle columns editable
				story_chapter_item.set_editable(0, false)
				story_chapter_item.set_editable(1, true)
				
				# Add a close button to tree item
				story_chapter_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
				
				# Format tree item
				story_chapter_item.set_expand_right(0, true)
				story_chapter_item.set_expand_right(1, true)
				
				story_chapter_item.set_custom_bg_color(0, story_tree.chapter_heading_bg)
				story_chapter_item.set_custom_bg_color(1, story_tree.chapter_heading_bg)
				
				# Set tree item metadata
				story_chapter_item.set_metadata(0, "chapter_number")
				story_chapter_item.set_metadata(1, "chapter_title")
				
				var chapter_scenes : Dictionary = editor_root.story_data["chapters"][chapter_number]["scenes"]
				
				for x in chapter_scenes.keys().size():
					var story_scene_item : TreeItem = story_tree.create_item(story_chapter_item)
					
					var scene_number : String = chapter_scenes.keys()[x]
					
					story_scene_item.set_text(0, scene_number)
					
					story_scene_item.set_text(1, chapter_scenes[scene_number]["name"])
					
					story_scene_item.set_tooltip(1, chapter_scenes[scene_number]["script_path"])
					story_scene_item.set_meta("script_file", chapter_scenes[scene_number]["script_path"])
					
					story_scene_item.set_metadata(0, "scene_number")
					story_scene_item.set_metadata(1, "scene_title")
					
					story_scene_item.set_editable(1, true)
					
					story_scene_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))


func get_tree_data() -> Dictionary:
	var story_tree_dictionary : Dictionary = {}
	
	var chapter_dict : Dictionary = {}
	
	var chapter_item : TreeItem = story_tree.get_root().get_children()
	
	while is_instance_valid(chapter_item):
		var scene_dict : Dictionary = {}
		
		var scene_item : TreeItem = chapter_item.get_children()
		
		while is_instance_valid(scene_item):
			if story_tree.current_opened:
				if story_tree.current_opened == scene_item:
					if story_tree.current_opened.has_meta("script_file"):
						scene_dict[str(scene_item.get_text(0))] = {
							"name": scene_item.get_text(1),
							"script_path": story_tree.current_opened.get_meta("script_file")
						}
					else:
						scene_dict[str(scene_item.get_text(0))] = {
							"name": scene_item.get_text(1),
							"script_path": scene_item.get_tooltip(1)
						}
				else:
					scene_dict[str(scene_item.get_text(0))] = {
						"name": scene_item.get_text(1),
						"script_path": scene_item.get_tooltip(1)
					}
			else:
				scene_dict[str(scene_item.get_text(0))] = {
					"name": scene_item.get_text(1),
					"script_path": scene_item.get_tooltip(1)
				}
			
			scene_item = scene_item.get_next()
		
		chapter_dict[chapter_item.get_text(0)] = {
			"title": chapter_item.get_text(1),
			"scenes": scene_dict
		}
		
		chapter_item = chapter_item.get_next()
	
	story_tree_dictionary["chapters"] = chapter_dict
	
	return story_tree_dictionary


func _reset() -> void:
	story_tree.clear()
	story_tree.current_selected = null
	story_tree.current_opened = null
	new_scene.disabled = true
	scene_title.get_node("Label").text = ""
	scene_title.hide()
	action_list._on_MenuFoldButtons_toggled(false)
	scene_actions._reset()
	preview._reset()
	scene_actions.vbar.hide()


func _setup_ui() -> void:
	# Story tree
	get_object_ref(story_tree_path, "story_tree")
	
	# Story tree buttons
	get_object_ref(add_chapter_path, "add_chapter")
	get_object_ref(new_scene_path, "new_scene")
	
	add_chapter.connect("pressed", self, "_on_add_chapter_pressed")
	new_scene.connect("pressed", self, "_on_new_scene_pressed")
	
	story_tree.editor_root = self
	story_tree.chapter_button = add_chapter
	story_tree.scene_button = new_scene
	
	new_scene.disabled = true
	
	# Scene Action List
	get_object_ref(action_list_path, "action_list")
	get_object_ref(scene_actions_path, "scene_actions")
	get_object_ref(scene_actions_editor_panel_path, "scene_actions_editor_panel")
	
	# Scene Actions Editor:
	get_object_ref(scene_title_path, "scene_title")
	
	# Preview
	get_object_ref(preview_path, "preview")


func _setup_grab_handles() -> void:
	get_object_ref(left_panel_v_handle_path, "left_panel_v_handle")
	get_object_ref(left_panel_v_handle_a_path, "left_panel_v_handle_a")
	get_object_ref(left_panel_v_handle_b_path, "left_panel_v_handle_b")
	
	get_object_ref(center_h_handle_path, "center_h_handle")
	get_object_ref(center_h_handle_a_path, "center_h_handle_a")
	get_object_ref(center_h_handle_b_path, "center_h_handle_b")
	
	get_object_ref(main_v_handle_path, "main_v_handle")
	get_object_ref(main_v_handle_a_path, "main_v_handle_a")
	get_object_ref(main_v_handle_b_path, "main_v_handle_b")
	
	# Resizer Variables
	if left_panel_v_handle:
		left_panel_v_handle.A = left_panel_v_handle_a
		left_panel_v_handle.B = left_panel_v_handle_b
	
	if center_h_handle:
		center_h_handle.A = center_h_handle_a
		center_h_handle.B = center_h_handle_b
		center_h_handle._setup_init_flags()
	
	if main_v_handle:
		main_v_handle.A = main_v_handle_a
		main_v_handle.B = main_v_handle_b


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
