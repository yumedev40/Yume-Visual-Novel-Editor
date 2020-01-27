extends Node


#warnings-disable
func _ready() -> void:
	pass

func _gen_template_scenes(dir_path: String) -> void:
	# Generate scene templates
	
	# Create new instance of game control singleton
	var controller_singleton_ref : GDScript = load("res://addons/Yume_VisualNovelEditor/AutoLoad_Scripts/yume_game_controller_singleton.gd")
	
	var controller_singleton_data : String = controller_singleton_ref.source_code
	
	var new_controller_instance : GDScript = GDScript.new()
	
	controller_singleton_data = controller_singleton_data.replace('"project_directory":null', str('"project_directory":"', dir_path,'"'))
	
	controller_singleton_data = controller_singleton_data.replace('"game_data":null', str('"game_data":"', dir_path,'/game_data"'))
	
	controller_singleton_data = controller_singleton_data.replace('"story_data":null', str('"story_data":"', dir_path,'/story_data"'))
	
	controller_singleton_data = controller_singleton_data.replace('"game_scenes":null', str('"game_scenes":"', dir_path,'/game_scenes"'))
	
	new_controller_instance.set_source_code(controller_singleton_data)
	
	ResourceSaver.save(str(dir_path, "/game_data/yume_game_controller.gd"), new_controller_instance)
	
	
	
	
	# Create new instance of VN Game scene
	var vn_main_resource : PackedScene = load("res://addons/Yume_VisualNovelEditor/Template_Scenes/VN_Components/VN_Game_Scene.tscn")
	var vn_main_instance : Object = vn_main_resource.instance()
	
	# Duplicate instance and resources
	vn_main_instance = vn_main_instance.duplicate(8)
	
	# Set node name
	vn_main_instance.name = "VN_Game_Scene"
	
	# Recursively set vn_main instance child nodes owner to vn_main instance root
	_set_node_tree_owner(_filter_array(_get_object_child_nodes(vn_main_instance)), vn_main_instance)
	
	# Pack the new main menu scene
	var vn_main_packed_scene : PackedScene = PackedScene.new()
	vn_main_packed_scene.pack(vn_main_instance)
	
	# Save packed scene resource
	ResourceSaver.save( str(dir_path, "/", "game_scenes", "/", "game_main", "/", "VN_Main", ".tscn"), vn_main_packed_scene, 64)
	
	# Free menu instance
	vn_main_instance.queue_free()
	
	
	
	
	# Create new instance of Main Menu template scene
	var main_menu_resource : PackedScene = load("res://addons/Yume_VisualNovelEditor/Template_Scenes/Menus/MainMenu.tscn")
	var main_menu_instance : Object = main_menu_resource.instance()
	
	# Duplicate instance and resources
	main_menu_instance = main_menu_instance.duplicate(8)
	
	# Set node name
	main_menu_instance.name = "Main_Menu"
	
	# Recursively set main menu instance child nodes owner to main menu instance root
	_set_node_tree_owner(_filter_array(_get_object_child_nodes(main_menu_instance)), main_menu_instance)
	
	# Generate menu script
	var main_menu_script_generator : Object = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_Component_Scripts/main_menu_script_generator.gd").new()
	
	var menu_gdscript : GDScript = main_menu_script_generator.generate_menu_script(main_menu_instance)
	
	# Save menu script
	ResourceSaver.save( str(dir_path, "/", "game_scenes", "/", "main_menu", "/", "Main_Menu", ".gd"), menu_gdscript, 64)
	
	# Add main menu script
	main_menu_instance.set_script(menu_gdscript)
	
	# Pack the new main menu scene
	var main_menu_packed_scene : PackedScene = PackedScene.new()
	main_menu_packed_scene.pack(main_menu_instance)
	
	# Save packed scene resource
	ResourceSaver.save( str(dir_path, "/", "game_scenes", "/", "main_menu", "/", "Main_Menu", ".tscn"), main_menu_packed_scene, 64)
	
	# Free menu instance
	main_menu_instance.queue_free()
	
	# Free script_generator
	main_menu_script_generator.queue_free()
	
	
	
	
	
	
	
	
	# Print debug message
	print("Visual novel template scenes generated")
	
	# Free generator once completed
	self.queue_free()




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


func _set_node_tree_owner(tree:Array, root: Object) -> void:
	for i in tree.size():
		if i is Object:
			i.set_owner(root)
