tool
extends Control

var dialogue_box := preload("res://addons/Yume_VisualNovelEditor/Template_Scenes/VN_Components/Textboxes/Textbox_Scenes/Default_Dialogue_Box.tscn")


#warnings-disable
func _ready() -> void:
	_reset()

func _reset() -> void:
	for i in get_children():
		i.free()
	
	var new_box := dialogue_box.instance()
	add_child(new_box)
	new_box.name = "Dialogue_Box"
	new_box.hide()
