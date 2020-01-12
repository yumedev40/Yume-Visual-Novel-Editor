extends "res://addons/Yume_VisualNovelEditor/Editor/Action_Components/ActionNodeClass.gd"


#warnings-disable
func _ready() -> void:
	add_action_tag("debug_message")
	add_action_tag("debug_options")
	build_ui()
