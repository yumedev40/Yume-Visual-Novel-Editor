extends "res://addons/Yume_VisualNovelEditor/Editor/Action_Components/ActionNodeClass.gd"


#warnings-disable
func _ready() -> void:
	add_action_tag("color_picker")
	add_action_tag("transition_settings")
	add_action_tag("image")
	build_ui()



