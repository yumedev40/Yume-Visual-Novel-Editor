tool
extends EditorPlugin

var editor_ui : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Yume_VN_Editor.tscn")
var editor_icon : StreamTexture = preload("res://addons/Yume_VisualNovelEditor/Editor/icon.png")

var editor_ui_instance : Object

signal autoload




#warnings-disable
func _enter_tree():
	editor_ui_instance = editor_ui.instance()
	get_editor_interface().get_editor_viewport().add_child(editor_ui_instance)
	
	make_visible(false)
	
	connect("autoload", self, "_set_controller_autoload")

func _exit_tree():
	editor_ui_instance.queue_free()
	
	if is_connected("autoload", self, "_set_controller_autoload"):
		disconnect("autoload", self, "_set_controller_autoload")

func _ready():
	pass

func has_main_screen():
	return true

func make_visible(visible):
	if visible:
		editor_ui_instance.show()
		if editor_ui_instance.run_first_time:
			editor_ui_instance.home_screen_fade_in()
			editor_ui_instance.run_first_time = false
		
		if !editor_ui_instance.editor_interface:
			editor_ui_instance.editor_interface = get_editor_interface()
		
		if !editor_ui_instance.plugin_root:
			editor_ui_instance.plugin_root = self
		
#		if !OS.is_in_low_processor_usage_mode():
#			OS.set_low_processor_usage_mode(true) 
	else:
		editor_ui_instance.hide()
#		if OS.is_in_low_processor_usage_mode():
#			OS.set_low_processor_usage_mode(false) 

func get_plugin_name():
	return "Yume"

func get_plugin_icon():
	return editor_icon

func save_external_data() -> void:
	editor_ui_instance._save_project()



func _set_controller_autoload(file_name:String, file_path:String) -> void:
	if Engine.has_singleton(file_name):
		remove_autoload_singleton(file_name)
	
	add_autoload_singleton(file_name, file_path)

