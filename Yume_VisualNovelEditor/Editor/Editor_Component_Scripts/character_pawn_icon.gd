tool
extends VBoxContainer

export(Color) var focused_color : Color = Color.white
export(Color) var not_focused_color : Color = Color.white
var current : bool = true setget set_current


# warnings-disable
func _ready() -> void:
	pass


func set_current(flag:bool) -> void:
	if !flag:
		modulate = not_focused_color
	else:
		modulate = focused_color

func set_name(new_name:String) -> void:
	$Label.text = new_name

func set_tooltip(new_name:String) -> void:
	$Label.hint_tooltip = new_name
