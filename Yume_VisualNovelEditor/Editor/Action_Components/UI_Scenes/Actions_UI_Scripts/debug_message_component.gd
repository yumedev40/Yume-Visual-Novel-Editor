tool
extends Node

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

onready var text_box : Object = $TextEdit
onready var title : Object = $Label
onready var breakpoint_icon : Object = $TextureRect

var breakpoint_icon_image : StreamTexture = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/breakpoint_icon.png")

const default_text : String = "Debug message Text"
var debug_message : String = default_text setget set_debug_message, get_debug_message

export(Color) var string_color : Color = Color.white
export(Color) var warning_color : Color = Color.yellow
export(Color) var error_color : Color = Color.red



#warnings-disable
func _ready() -> void:
	set_meta("debug_message_component", true)
	
	text_box.connect("text_changed", self, "_on_text_box_changed")
	
	node_container_base.preview_available = true
	
	if has_meta("set_default_text"):
		node_container_base.get_node("HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewLabel").set_bbcode(get_meta("set_default_text"))
		node_container_base.get_node("HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewLabel").hint_tooltip = get_meta("set_default_text")
	
	text_box.connect("focus_entered", self, "_focus_entered")
	text_box.connect("focus_exited", self, "_focus_exited")
	
	set_process_input(false)
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("debug_message"):
			self.set_debug_message(action_node_root.loaded_action_data["debug_message"])



# Main Action Info
func get_action_data() -> String:
	return get_debug_message()



func _focus_entered() -> void:
	set_process_input(true)

func _focus_exited() -> void:
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			text_box.release_focus()
			set_process_input(false)


func set_debug_message(message_text:String) -> void:
	if message_text.replace(" ","") != "":
		debug_message = message_text
	else:
		debug_message = default_text
		push_warning("Debug message component requires a message string, reverting to default message")
	
	if text_box.text != message_text:
		text_box.text = message_text
	
	node_container_base.set_preview(false, message_text)


func get_debug_message() -> String:
	return debug_message


func _on_text_box_changed() -> void:
	self.debug_message = text_box.text


func _on_debug_mode_changed(mode:int) -> void:
	if !text_box:
		text_box = $TextEdit
	
	match mode:
		0:
			text_box.set("custom_colors/font_color", null)
			node_container_base.preview_textbox.set("custom_colors/default_color", null)
		1:
			text_box.set("custom_colors/font_color", warning_color)
			node_container_base.preview_textbox.set("custom_colors/default_color", warning_color)
		2:
			text_box.set("custom_colors/font_color", error_color)
			node_container_base.preview_textbox.set("custom_colors/default_color", error_color)


func _on_breakpoint_mode_changed(flag:bool) -> void:
	if !title || !breakpoint_icon:
		title = $Label
		breakpoint_icon = $TextureRect
	
	if !breakpoint_icon_image:
		breakpoint_icon_image = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/breakpoint_icon.png")
	
	
	if flag:
		title.set("custom_colors/font_color", Color.red)
		breakpoint_icon.show()
		node_container_base.set_preview(false, null, breakpoint_icon_image)
	else:
		title.set("custom_colors/font_color", null)
		breakpoint_icon.hide()
		node_container_base.set_preview(false, null, null, 2)
