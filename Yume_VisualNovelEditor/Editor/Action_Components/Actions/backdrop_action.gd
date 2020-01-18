extends "res://addons/Yume_VisualNovelEditor/Editor/Action_Components/ActionNodeClass.gd"


#warnings-disable
func _ready() -> void:
	add_action_tag("image")
	add_action_tag("transition_settings")
	add_action_tag("toggle")
	build_ui()


