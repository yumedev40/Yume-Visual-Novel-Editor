tool
extends TextureRect

export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var scene_actions_container_path : NodePath
var scene_actions_container : Object

export(NodePath) var preview_scene_button_path : NodePath
var preview_scene_button : Object

export(NodePath) var pause_preview_button_path : NodePath
var pause_preview_button : Object

export(NodePath) var stop_preview_button_path : NodePath
var stop_preview_button : Object

export(NodePath) var preview_running_sprite_path : NodePath
var preview_running_sprite : Object



onready var viewport : Object = $"Viewport"

enum PREVIEW {IDLE, RUNNING, UPDATING, PAUSED}
var preview_state : int = PREVIEW.IDLE

var preview_scene : Object




#warnings-disable
func _ready() -> void:
	get_object_ref(editor_root_path, "editor_root")
	
	get_object_ref(scene_actions_container_path, "scene_actions_container")
	
	
	get_object_ref(preview_scene_button_path, "preview_scene_button")
	
	get_object_ref(pause_preview_button_path, "pause_preview_button")
	
	get_object_ref(stop_preview_button_path, "stop_preview_button")
	
	get_object_ref(preview_running_sprite_path, "preview_running_sprite")
	
	
	preview_scene_button.connect("pressed", self, "_preview_scene")
	
	pause_preview_button.connect("pressed", self, "_pause_preview")
	
	stop_preview_button.connect("pressed", self, "_stop_preview")



func _setup() -> void:
	texture = viewport.get_texture()
	viewport.size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
	
	if viewport.get_child_count() < 2:
		var VN_Main : Object = load(editor_root.project_scene_list["game_scene"]).instance()
		VN_Main.debug_mode = true
		
		yield(get_tree().create_timer(0.1),"timeout")

		viewport.add_child(VN_Main)
		preview_scene = VN_Main
		VN_Main.connect("completed", self, "_preview_completed")


func _reset() -> void:
	preview_state = PREVIEW.IDLE
	
	pause_preview_button.pressed = false
	stop_preview_button.disabled = false
	
	preview_running_sprite.get_node("AnimatedSprite").playing = true
	
	preview_scene_button.show()
	pause_preview_button.hide()
	stop_preview_button.hide()
	preview_running_sprite.hide()
	
	preview_scene_button.disabled = true
	
	if preview_scene:
		if preview_scene.is_connected("completed", self, "_preview_completed"):
			preview_scene.disconnect("completed", self, "_preview_completed")
	
	preview_scene = null
	
	for i in viewport.get_children():
		if !i is Camera2D:
			i.queue_free()


func reset_ui() -> void:
	preview_state = PREVIEW.IDLE
	
	pause_preview_button.pressed = false
	stop_preview_button.disabled = false
	
	preview_running_sprite.get_node("AnimatedSprite").playing = true
	
	preview_scene_button.show()
	pause_preview_button.hide()
	stop_preview_button.hide()
	preview_running_sprite.hide()
	
	preview_scene_button.disabled = true


func _preview_completed() -> void:
	reset_ui()
	preview_scene_button.disabled = false




func _preview_scene() -> void:
	preview_state = PREVIEW.RUNNING
	
	preview_scene_button.hide()
	pause_preview_button.show()
	stop_preview_button.show()
	preview_running_sprite.show()
	preview_running_sprite.get_node("AnimatedSprite").playing = true
	
	if preview_scene:
		var open_scene_data : Dictionary = scene_actions_container.open_scene_info
#		print(open_scene_data)
		
		preview_scene.raw_edit_preview = false
		
		preview_scene.preview_complete_scene([open_scene_data["chapter_number"], open_scene_data["scene_number"]], str(open_scene_data["scene_script_filepath"].trim_suffix(".yscndata"), ".yscn"))

func _pause_preview() -> void:
	if pause_preview_button.pressed:
		preview_state = PREVIEW.PAUSED
		
		stop_preview_button.disabled = true
		preview_running_sprite.get_node("AnimatedSprite").playing = false
	else:
		preview_state = PREVIEW.RUNNING
		
		stop_preview_button.disabled = false
		preview_running_sprite.get_node("AnimatedSprite").playing = true

func _stop_preview() -> void:
	preview_state = PREVIEW.IDLE
	
	pause_preview_button.pressed = false
	
	preview_scene_button.show()
	pause_preview_button.hide()
	stop_preview_button.hide()
	preview_running_sprite.hide()
	
	preview_scene._reset()






func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )

