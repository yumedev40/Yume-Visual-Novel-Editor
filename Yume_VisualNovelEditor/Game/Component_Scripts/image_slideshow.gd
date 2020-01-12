tool
extends TextureRect

export(float, 0.0, 1.0, 0.1) var transition_amount : float = 0.0 setget set_ab_transition_amount, get_ab_transition_amount

export(StreamTexture) var image_a : StreamTexture setget set_image_a, get_image_a

export(StreamTexture) var image_b : StreamTexture setget set_image_b, get_image_b

export(float, 0.0, 1.0, 0.1) var modulate_amount : float = 0.0 setget set_modulate_amount, get_modulate_amount

export(Color) var modulate_color : Color = Color.white setget set_modulate_color, get_modulate_color




# shader vars
var shader : Object

var transition_var_path : String = "shader_param/transition_amount"

var image_a_var_path : String = "shader_param/image_a"

var image_b_var_path : String = "shader_param/image_b"

var modulate_value_var_path : String = "shader_param/modulate_amount"

var modulate_color_var_path : String = "shader_param/modulate_color"







#warnings-disable
func _ready() -> void:
	shader = material


#setget
func set_ab_transition_amount(value:float) -> void:
	transition_amount = value
	material.set(transition_var_path, value)

func get_ab_transition_amount() -> float:
	return transition_amount


func set_image_a(image:StreamTexture) -> void:
	image_a = image
	material.set(image_a_var_path, image)

func get_image_a() -> StreamTexture:
	return image_a

func set_image_b(image:StreamTexture) -> void:
	image_b = image
	material.set(image_b_var_path, image)

func get_image_b() -> StreamTexture:
	return image_b


func set_modulate_amount(value:float) -> void:
	modulate_amount = value
	material.set(modulate_value_var_path, value)

func get_modulate_amount() -> float:
	return modulate_amount

func set_modulate_color(color:Color) -> void:
	modulate_color = color
	material.set(modulate_color_var_path, color)

func get_modulate_color() -> Color:
	return modulate_color



