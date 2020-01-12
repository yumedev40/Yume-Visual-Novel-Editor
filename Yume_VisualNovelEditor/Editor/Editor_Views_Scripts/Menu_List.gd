tool
extends Tabs

onready var editor_root : Object = $"../../.."

export(NodePath) var center_h_handle_path : NodePath
export(NodePath) var center_h_handle_a_path : NodePath
export(NodePath) var center_h_handle_b_path : NodePath

var center_h_handle : Object
var center_h_handle_a : Object
var center_h_handle_b : Object

export(NodePath) var scene_tree_path : NodePath
var scene_tree : Object
var tree_root : TreeItem

export(NodePath) var preview_rect_path : NodePath
var preview_rect : Object
export(NodePath) var preview_path : NodePath
var preview : Object

var currently_selected = null



#warnings-disable
func _ready() -> void:
	# Setup UI
	_setup_grab_handles()
	_setup_preview_nodes()
	
	# Get tree node
	get_object_ref(scene_tree_path, "scene_tree")
	
	# Connect signals
	scene_tree.connect("item_selected", self, "_item_selected")
	scene_tree.connect("item_activated", self, "_item_activated")
	scene_tree.connect("nothing_selected", self, "_nothing_selected")


func _setup() -> void:
	# Setup tree node
	_setup_tree()




func _item_selected():
	var items : TreeItem = tree_root.get_children()
	
	# Clear highlight bg color from tree items
	while is_instance_valid(items):
		items.clear_custom_bg_color(0)
		items = items.get_next()
	
	
	# Setup preview when tree item is selected
	if currently_selected != scene_tree.get_selected():
		# Get reference to currently selected tree item
		currently_selected = scene_tree.get_selected()
		# Setup Preview Image
		_setup_preview_image(scene_tree.get_selected().get_tooltip(0))
		
		currently_selected.set_custom_bg_color(0, Color8(106, 158, 234))


func _item_activated() -> void:
	# If tree item is double clicked
	if scene_tree is Tree:
		# Get scene filepath from tree item tooltip
		var tree_item : TreeItem = scene_tree.get_selected()
		var file_request = tree_item.get_tooltip(0)
		# Open scene at tooltip path via editor
		editor_root.editor_root.editor_interface.open_scene_from_path(file_request)





# Tree methods

func _setup_tree() -> void:
	# Populate tree node with scenes
	if scene_tree is Tree:
		tree_root = scene_tree.create_item()
		tree_root.set_text(0, "Scenes found")
		
		# Go through scene list and add matching tree items
		if editor_root.project_scene_list.keys().size() > 0:
			for i in editor_root.project_scene_list.keys().size():
				if editor_root.project_scene_list[editor_root.project_scene_list.keys()[i]] != "":
					# Setup tree item name and filepath tooltip
					var scene_path : String = editor_root.project_scene_list[editor_root.project_scene_list.keys()[i]]
					
					var scene_parse : Array = editor_root.project_scene_list[editor_root.project_scene_list.keys()[i]].split("/")
					
					var scene_name : String = scene_parse[scene_parse.size() - 1]
					
					var tree_item : TreeItem = scene_tree.create_item(tree_root)
					tree_item.set_text(0, scene_name)
					tree_item.set_tooltip(0, scene_path)
					
					tree_item.set_selectable(0, true)


func _refresh_list() -> void:
	# Clear tree and then rebuild it
	if scene_tree is Tree:
		scene_tree.clear()
		_setup_tree()





# Preview methods

func _nothing_selected() -> void:
	# Reset preview rect if nothing is selected
	if preview_rect is TextureRect && preview is Viewport:
		preview_rect.texture = null
	
	# Deselect the currently selected tree item
	if scene_tree.get_selected():
		scene_tree.get_selected().deselect(0)
	
	# Reset the currently selected item
	if currently_selected:
		currently_selected = null
	
	# Clear highlight bg color from tree items
	var items : TreeItem = tree_root.get_children()
	
	while is_instance_valid(items):
		items.clear_custom_bg_color(0)
		items = items.get_next()
	
	# Clear the viewport of all child nodes but the camera
	_clear_viewport()


func _setup_preview_image(path:String) -> void:
	if preview_rect is TextureRect && preview is Viewport:
		# Duplicate an instance of the scene
		var scene_node : Object = load(path).instance()
		
		# Add instance as child of viewport
		preview.add_child(scene_node)
		
		# Setup preview texture rect
		preview.size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
		preview_rect.texture = preview.get_texture()











# Helper Methods

func _reset() -> void:
	# Clear tree
	if scene_tree is Tree:
		scene_tree.clear()
	
	preview_rect.texture = null
	currently_selected = null
	_clear_viewport()


func _clear_viewport() -> void:
	# Clear the viewport of any instanced scenes
	for i in preview.get_children():
		if !i is Camera2D:
			i.queue_free()


func _setup_preview_nodes() -> void:
	get_object_ref(preview_path, "preview")
	get_object_ref(preview_rect_path, "preview_rect")


func _setup_grab_handles() -> void:
	get_object_ref(center_h_handle_path, "center_h_handle")
	get_object_ref(center_h_handle_a_path, "center_h_handle_a")
	get_object_ref(center_h_handle_b_path, "center_h_handle_b")
	
	# Resizer Variables
	if center_h_handle:
		center_h_handle.A = center_h_handle_a
		center_h_handle.B = center_h_handle_b
		center_h_handle._setup_init_flags()


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
