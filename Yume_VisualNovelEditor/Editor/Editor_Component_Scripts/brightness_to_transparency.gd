tool
extends ColorRect

var set_start : bool = false
var set_modulate_ : bool = false
var color_ : Color = Color.white setget set_color



#warnings-disable
func _ready() -> void:
	material = material.duplicate()
	set_process(true)

func set_color(col:Color) -> void:
	color_ = col
	material.set("shader_param/color", col)

func set_modulate_flag(flag:bool) -> void:
	material.set("shader_param/modulate", flag)

func adjust_transparency(color:Color) -> void:
	var value : float = color.r
	material.set("shader_param/transparency", value)

func set_image_flag(flag:bool) -> void:
	material.set("shader_param/use_image", flag)

func set_image(texture:StreamTexture) -> void:
	material.set("shader_param/image", texture)



func _process(delta: float) -> void:
	if set_start:
		material.set("shader_param/transparency", 1.0)
	if set_modulate_:
		material.set("shader_param/modulate", true)
	
	set_process(false)

