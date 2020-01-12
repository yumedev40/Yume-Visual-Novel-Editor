extends "res://addons/Yume_VisualNovelEditor/Editor/Action_Components/ActionNodeClass.gd"


#warnings-disable
func _ready() -> void:
	add_action_tag("text_string")
	add_action_tag("text_box")
	build_ui()

