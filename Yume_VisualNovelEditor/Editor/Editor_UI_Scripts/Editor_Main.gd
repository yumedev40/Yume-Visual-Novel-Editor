tool
extends HBoxContainer

onready var editor_root : Object = $".."

# Project Settings

var project_version : String = ""
var project_name : String = ""
var project_directory : String = ""
var project_filepath : String = ""

var project_scene_list : Dictionary = {}

var story_data : Dictionary = {}



export(NodePath) var views_container_path : NodePath
var views_container : Object

export(NodePath) var preview_viewport_path : NodePath
var preview_viewport : Object


#warnings-disable
func _ready() -> void:
	 get_object_ref(views_container_path, "views_container")
	 get_object_ref(preview_viewport_path, "preview_viewport")


func _reset():
	views_container.current_tab = 0
	
	for i in views_container.get_children():
		if i.has_method("_reset"):
			i._reset()


func _setup():
	for i in views_container.get_children():
		if i.has_method("_setup"):
			i._setup()
	
	preview_viewport._setup()


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
