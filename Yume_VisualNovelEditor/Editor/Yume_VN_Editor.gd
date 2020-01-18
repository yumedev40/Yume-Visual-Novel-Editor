tool
extends VBoxContainer

export(String) var plugin_version : String = "0.1.0"

# Editor Windows
export(NodePath) var home_screen_path : NodePath
export(NodePath) var editor_screen_path : NodePath

var home_screen : Object
var editor_screen : Object


# Editor UI
export(NodePath) var new_project_button_path : NodePath
var new_project_button : Object

export(NodePath) var load_project_button_path : NodePath
var load_project_button : Object

export(NodePath) var project_details_path : NodePath
var project_details : Object

export(NodePath) var file_button_path : NodePath
var file_button : Object


# Home Screen Components
var new_project_message : String = "[center]Create A New Visual Novel Project[/center]"
var load_project_message : String = "[center]Load Existing Visual Novel Project[/center]"

export(NodePath) var welcome_mat_path : NodePath
var welcome_mat : Object

export(NodePath) var description_box_path : NodePath
var description_box : Object

export(NodePath) var version_box_path : NodePath
var version_box : Object

export(NodePath) var new_project_window_path : NodePath
var new_project_window : Object
var new_project_directory_path : Object
var new_project_name: Object
var new_project_error_label : Object
var new_project_gen_template_scenes : Object
var new_project_create_button : Object

export(NodePath) var load_project_window_path : NodePath
var load_project_window : Object

export(NodePath) var new_project_directory_dialogue_path : NodePath
var new_project_directory_dialogue : Object

var gen_template_scenes : bool = true


# Editor Screen
export(NodePath) var scene_list_tree_path : NodePath
var scene_list_tree : Object


# Internal Variables
var editor_interface : Object
var plugin_root : Object

var run_first_time : bool = true
var home_menu_tween : Tween = Tween.new()

var project_open : bool = false


# Signals
signal editor_visibility_changed




#warnings-disable
func _enter_tree() -> void:
	print("Yume Editor Initialized")


func _ready() -> void:
	# Editor Setup
	_setup_editor_ui()
	_setup_home_screen()
	_setup_new_project_window()
	_setup_load_project_window()
	_setup_ui_shortcuts()
	
	home_screen.show()
	editor_screen.hide()




### EDITOR ###
#------------#

# Editor UI:
#-----------
func _setup_editor_ui() -> void:
	# Setup Editor UI
	
	## Editor Windows
	get_object_ref(home_screen_path, "home_screen")
	get_object_ref(editor_screen_path, "editor_screen")
	
	## Top Bar UI
	get_object_ref(project_details_path, "project_details")
	
	## Top Bar Buttons
	get_object_ref(file_button_path, "file_button")
	file_button.get_popup().connect("id_pressed", self, "_on_file_menu_option_selected")
	
	for i in file_button.get_popup().get_item_count():
		match i:
			0:
				file_button.get_popup().set_item_tooltip(i, "Create a new project.")


func _on_file_menu_option_selected(ID:int) -> void:
	match ID:
		0:
			_on_NewProject_pressed()
		1:
			_on_LoadProject_pressed()
		2:
			_save_project()
		3:
			print("Save as")
			pass
		4:
			_on_close_project()
		_:
			print(str("No defined action for File Menu Option: ", ID))


func _setup_home_screen() -> void:
	# Setup Home Screen
	get_object_ref(welcome_mat_path, "welcome_mat")
	welcome_mat.set("modulate", Color(1,1,1,0))
	add_child(home_menu_tween)
	
	get_object_ref(new_project_button_path, "new_project_button")
	get_object_ref(load_project_button_path, "load_project_button")
	
	get_object_ref(description_box_path, "description_box")
	
	get_object_ref(version_box_path, "version_box")
	version_box.set_text(str("ver. ", plugin_version))


func home_screen_fade_in(time : float = 0.2) -> void:
	yield(get_tree().create_timer(0.2), "timeout")
	home_menu_tween.stop_all()
	home_menu_tween.interpolate_property(welcome_mat, "modulate", Color(1,1,1,0), Color(1,1,1,1), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	home_menu_tween.start()


func _setup_new_project_window() -> void:
	# New Project Window
	get_object_ref(new_project_window_path, "new_project_window")
	new_project_window.set_as_toplevel(true)
	
	new_project_name = new_project_window.get_node("PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/LineEdit")
	
	new_project_name.connect("text_changed", self, "_on_new_project_name_changed")
	new_project_name.connect("text_entered", self, "_on_new_project_name_entered")
	
	new_project_directory_path = new_project_window.get_node("PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer3/LineEdit")
	
	new_project_directory_path.connect("text_changed", self, "_on_new_project_directory_changed")
	new_project_directory_path.connect("text_entered", self, "_on_new_project_directory_entered")
	
	new_project_error_label = new_project_window.get_node("PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer4/ErrorLabel")
	
	new_project_create_button = new_project_window.get_node("PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer4//VBoxContainer/CreateButton")
	
	new_project_create_button.connect("pressed", self, "_create_new_project")
	
	# Choose Directory Button
	new_project_window.get_node("PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer3/ChooseDirectory").connect("pressed", self, "_on_choose_new_project_directory")
	
	# New Project Directory File Dialogue 
	get_object_ref(new_project_directory_dialogue_path, "new_project_directory_dialogue")
	
	new_project_directory_dialogue.connect("dir_selected", self, "_new_project_window_directory_selected")
	
	# Generate Template Scenes
	new_project_gen_template_scenes = new_project_window.get_node("PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/GenerateTemplateScenes")
	
	new_project_gen_template_scenes.connect("toggled", self, "_gen_template_scenes_toggled")


func _on_choose_new_project_directory() -> void:
	new_project_directory_dialogue.popup_centered_ratio(0.5)


func _on_new_project_name_changed(new_text:String) -> void:
	new_project_create_button.disabled = true
	if new_text.length() < 1:
		_validate_project_settings()
	else:
		new_project_name.set("custom_colors/font_color",Color8(255, 255, 255))
		new_project_error_label.hide()


func _on_new_project_name_entered(new_text:String) -> void:
	new_project_create_button.disabled = true
	_validate_project_settings()


func _on_new_project_directory_changed(new_text:String) -> void:
	new_project_create_button.disabled = true
	new_project_directory_path.set("custom_colors/font_color",Color8(255, 255, 255))
	new_project_error_label.hide()


func _on_new_project_directory_entered(new_text:String) -> void:
	new_project_create_button.disabled = true
	_validate_project_settings()


func _gen_template_scenes_toggled(button_pressed:bool) -> void:
	gen_template_scenes = button_pressed


func _new_project_window_directory_selected(dir:String) -> void:
	new_project_directory_path.text = dir
	_validate_project_settings()


func _validate_project_settings() -> bool:
	var flag : bool = false
	new_project_error_label.hide()
	new_project_error_label.set_bbcode("")
	
	if _validate_dir():
		flag = true
		new_project_create_button.disabled = false
	else:
		flag = false
		new_project_create_button.disabled = true
	
	return flag


func _validate_dir() -> bool:
	var flag : bool = false
	
	# Check If Name Is Valid
	var project_name : String = new_project_name.text.replace(" ", "_")
	if project_name.length() < 1:
		flag = false
		_visual_validation_project_name_feedback(flag)
		new_project_error_label.show()
		new_project_error_label.append_bbcode(str("* There Is No Project Name Specified"))
		return flag
	else:
		_visual_validation_project_name_feedback(true)
	
	var regEx := RegEx.new()
	regEx.compile("[^\\w\\d]+")
	var regExResult : String = regEx.sub(project_name, "", true)
	if regExResult:
		new_project_name.text = regExResult
	
	# Check If Directory Exists
	var dir : Directory = Directory.new()
	if dir.dir_exists(str(new_project_directory_path.text)):
		flag = true
	else:
		flag = false
		_visual_validation_filepath_feedback(flag)
		new_project_error_label.show()
		new_project_error_label.append_bbcode(str("* The Specified Directory Does Not Exist:\n  > ", str(new_project_directory_path.text)))
		return false
	
	# Check If Directory Is Empty
	var files_found : Array = []
	var dirs_found : Array = []
	if dir.open(str(new_project_directory_path.text)) == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if dir.current_is_dir():
				dirs_found.append(filename)
			else:
				files_found.append(filename)
			filename = dir.get_next()
	else:
		flag = false
		_visual_validation_filepath_feedback(flag)
		new_project_error_label.show()
		new_project_error_label.append_bbcode(str("* The Specified Directory Could Not Be Accessed:\n  > ", str(new_project_directory_path.text)))
		return false
	
	if dirs_found.size() > 0:
		if dirs_found.has(str(new_project_name.text)):
			flag = false
			_visual_validation_filepath_feedback(flag)
			new_project_error_label.show()
			new_project_error_label.append_bbcode(str("* The Specified Directory Already Contains A Directory Named After This Project:\n  > ", str(new_project_directory_path.text, "/", new_project_name.text)))
			return false
	
	if files_found.size() > 0:
		flag = false
		_visual_validation_filepath_feedback(flag)
		new_project_error_label.show()
		new_project_error_label.append_bbcode(str("* The Specified Directory Contains One Or More Files.  Please Select Or Create An Empty Directory:\n  > ", str(new_project_directory_path.text)))
		return false
		
#		flag = true
#		_visual_validation_filepath_feedback(flag)
#		return true
	else:
		flag = true
		_visual_validation_filepath_feedback(flag)
		return true
	
	_visual_validation_filepath_feedback(flag)
	return flag


func _visual_validation_filepath_feedback(flag:bool) -> void:
	if flag:
		new_project_directory_path.set("custom_colors/font_color",Color8(89, 255, 142))
	else:
		new_project_directory_path.set("custom_colors/font_color",Color8(240, 41, 41))


func _visual_validation_project_name_feedback(flag:bool) -> void:
	if flag:
		new_project_name.set("custom_colors/font_color",Color8(255, 255, 255))
	else:
		new_project_name.set("custom_colors/font_color",Color8(240, 41, 41))


func _reset_new_project_window() -> void:
	new_project_name.text = "New Project"
	new_project_directory_path.text = "res://"
	new_project_create_button.disabled = true
	new_project_error_label.set_bbcode("")


func _create_new_project() -> void:
	# Hide Editor Window
	new_project_window.hide()
	
	# Create New Project Files And Directories
	_setup_new_project()
	
	# Change to editor mode
	_open_project()
	_reset_new_project_window()


func _setup_new_project() -> void:
	_setup_project_directory()
	_setup_project_initial_file()


func _setup_project_directory() -> void:
	var dir : Directory = Directory.new()
	var dirpath : String = str(new_project_directory_path.text)
	
	# Create Support Folders
	#-----------------------
	
	# Container Directory Name
	var scenes_directory : String = "game_scenes"
	var story_directory : String = "story_data"
	
	# Create Scene Folders
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "main_menu"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "settings_menu"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "game_main"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "end_menu"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "gallery_menu"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "save_load_menu"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "extra_menus"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "images"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "characters"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "dialogue_boxes"))
	dir.make_dir_recursive(str(dirpath, "/", scenes_directory, "/", "theme_files"))
	
	# Create Story Folders
	dir.make_dir_recursive(str(dirpath, "/", story_directory, "/", "story_files"))
	
	# Create Game Data Folders
	dir.make_dir_recursive(str(dirpath, "/", "game_data"))
	
	# Generate thumbnails folder
#	dir.make_dir_recursive(str(dirpath, "/", "_thumbs_"))


func _setup_project_initial_file() -> void:
	var file : File = File.new()
	
	var dirpath : String = str(new_project_directory_path.text)
	var filepath : String = str(dirpath, "/", new_project_name.text, ".yvnp")
	
	var project_data : Dictionary
	
	if gen_template_scenes:
		
		var template_generator : GDScript = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_Component_Scripts/template_scenes_generator.gd").new()
		
		template_generator._gen_template_scenes(dirpath)
		
		project_data = {
			"project_version": plugin_version,
			"project_name":  new_project_name.text,
			"project_directory": dirpath,
			"project_scene_list": {
				"controller": str(dirpath, "/game_data/yume_game_controller.gd"),
				"main_menu": str(dirpath, "/", "game_scenes", "/", "main_menu", "/", "Main_Menu", ".tscn"),
				"settings_menu": "",
				"game_scene": str(dirpath, "/", "game_scenes", "/", "game_main", "/", "VN_Main", ".tscn"),
				"end_scene": ""
			}
		}
		
		# Set new main menu as main scene
		ProjectSettings.set("application/run/main_scene", str(dirpath, "/", "game_scenes", "/", "main_menu", "/", "Main_Menu", ".tscn"))
		
	else:
		project_data = {
			"project_version": plugin_version,
			"project_name":  new_project_name.text,
			"project_directory": dirpath,
			"project_scene_list": {
				"controller": "",
				"main_menu": "",
				"settings_menu": "",
				"game_scene": "",
				"end_scene": ""
			}
		}
	
	
	# Create New Project File
	file.open(filepath, File.WRITE)
	file.store_line(to_json(project_data))
	file.close()
	
	
	# Create Story Data File
	var story_info : Dictionary = {}
	var story_file : File = File.new()
	story_file.open(str(dirpath, "/", "story_data", "/", "story_data",".yvndata"), File.WRITE)
	story_file.store_line(to_json(story_info))
	story_file.close()
	
	
	# Print debug message
	print("New visual novel project ", project_data["project_name"], " created")
	
	_setup_project_settings(project_data, story_info)


func _setup_load_project_window() -> void:
	# Load Project Window
	get_object_ref(load_project_window_path, "load_project_window")
	
	load_project_window.connect("file_selected", self, "_on_load_file_selected")


func _on_load_file_selected(path:String) -> void:
	var file : File = File.new()
	var data_dict : Dictionary
	var story_data_dict : Dictionary
	
	# Load Project File Data
	if file.file_exists(path):
		file.open(path, File.READ)
		data_dict = str2var(file.get_as_text())
		file.close()
		
		# Load Story Data
		var story_data_file : File = File.new()
		var story_data_filepath : String = str(data_dict["project_directory"], "/story_data/", "story_data", ".yvndata")
		
		if story_data_file.file_exists(story_data_filepath):
			story_data_file.open(story_data_filepath, File.READ)
			if str2var(story_data_file.get_as_text()):
				story_data_dict = str2var(story_data_file.get_as_text())
			story_data_file.close()
		else:
			story_data_dict = {}
		
		
		# Print debug message
		print("Visual novel project ", data_dict["project_name"], " loaded")
	else:
		push_error(str("Yume Visual Novel Project File could not be opened > ", path))
		return
	
	# Apply Data
	_setup_project_settings(data_dict, story_data_dict)
	
	# Change to editor mode
	_open_project()
	_reset_new_project_window()


func _open_project() -> void:
	# Set Project Open Property To True
	project_open = true
	
	editor_screen._reset()
	yield(get_tree().create_timer(0.02),"timeout")
	editor_screen._setup()
	
	# Switch to Editor View
	home_screen.hide()
	editor_screen.show()


func _on_close_project() -> void:
	# Play welcome animation if just closed project
	if project_open:
		welcome_mat.set("modulate", Color(1,1,1,0))
		home_screen_fade_in()
	
		# Set Project Open Property To False
		project_open = false
		
		# Reset Home Screen
		_reset_new_project_window()
		
		# Reset Editor Variables
		print(str("Visual novel project ", editor_screen.project_name, " closed"))
		_clear_project_variables()
		
		editor_screen._reset()
		
		# Switch to Home View
		home_screen.show()
		editor_screen.hide()


func _setup_project_settings(data:Dictionary, story:Dictionary) -> void:
	if data.has("project_version"):
		editor_screen.project_version = data["project_version"]
	if data.has("project_name"):
		editor_screen.project_name = data["project_name"]
	if data.has("project_directory"):
		editor_screen.project_directory = data["project_directory"]
	if data.has("project_directory") && data.has("project_name"):
		editor_screen.project_filepath = str(data["project_directory"],"/", data["project_name"])
	if data.has("project_scene_list"):
		editor_screen.project_scene_list = data["project_scene_list"]
		
		if data["project_scene_list"]["main_menu"] != "":
			# Set main menu as main scene
			ProjectSettings.set("application/run/main_scene", data["project_scene_list"]["main_menu"])
	
	# Setup game controller singleton
	if data.has("project_directory") && data.has("project_scene_list"):
		if data["project_scene_list"]["controller"] != "":
			var controller_base_name : String = data["project_scene_list"]["controller"].get_file().split(".")[0]
			plugin_root.emit_signal("autoload", controller_base_name, data["project_scene_list"]["controller"])
	
	if story:
		editor_screen.story_data = story
	else:
		editor_screen.story_data = {}
	
	
	if data.has("project_name"):
		project_details.set_bbcode(str("[right]Current Project - [color=#ffffff]", editor_screen.project_name, "[/color]"))


func _clear_project_variables() -> void:
	editor_screen.project_version = ""
	editor_screen.project_name = ""
	editor_screen.project_directory = ""
	editor_screen.project_filepath = ""
	editor_screen.project_scene_list = {}
	
	editor_screen.story_data = {}
	
	project_details.set_bbcode(str(""))


func _save_project() -> void:
	if project_open:
		var file : File = File.new()
		
		var dirpath : String = str(editor_screen.project_directory)
		var filepath : String = str(editor_screen.project_filepath)
		
		var project_data : Dictionary = {
			"project_version": editor_screen.project_version,
			"project_name":  editor_screen.project_name,
			"project_directory": editor_screen.project_directory,
			"project_scene_list": editor_screen.project_scene_list
		}
		
		# Create New Project File
		file.open(str(filepath, ".yvnp"), File.WRITE)
		file.store_line(to_json(project_data))
		file.close()
		
		editor_screen.views_container.get_node("Story Editor").scene_actions_editor_panel.save()
		
		var story_data_file : File = File.new()
		var story_data : Dictionary = editor_screen.views_container.get_node("Story Editor").get_tree_data()
		
		story_data_file.open(str(dirpath, "/story_data/story_data", ".yvndata"), File.WRITE)
		story_data_file.store_line(to_json(story_data))
		story_data_file.close()
		
		_setup_project_settings(project_data, story_data)
		
		print(str("Visual Novel Project ", editor_screen.project_name, " saved"))


# Home Menu
#-----------
func _on_NewProject_pressed() -> void:
	_reset_new_project_window()
	new_project_window.rect_size = Vector2.ZERO
	new_project_window.popup_centered_minsize(new_project_window.rect_min_size)
	_validate_dir()

func _on_NewProject_mouse_entered() -> void:
	description_box.set_bbcode(str(new_project_message))

func _on_NewProject_mouse_exited() -> void:
	description_box.set_bbcode(str(""))



func _on_LoadProject_pressed() -> void:
	load_project_window.popup_centered_ratio(0.5)

func _on_LoadProject_mouse_entered() -> void:
	description_box.set_bbcode(str(load_project_message))

func _on_LoadProject_mouse_exited() -> void:
	description_box.set_bbcode(str(""))



func _setup_ui_shortcuts() -> void:
	pass









# Helper Methods

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
