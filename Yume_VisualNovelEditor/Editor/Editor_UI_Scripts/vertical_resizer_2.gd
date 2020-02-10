tool
extends Panel

var A : Object
var B : Object
var C : Object

export(float, 0, 0.1, 0.001) var damp : float = 0.003

var active : bool = false





#warnings-disable
func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if active && A && B:
			A.size_flags_stretch_ratio += event.relative.y * damp
			B.size_flags_stretch_ratio -= event.relative.y * damp
			C.size_flags_stretch_ratio -= event.relative.y * damp
			
			A.size_flags_stretch_ratio = clamp(A.size_flags_stretch_ratio, 0.4, 2)
			B.size_flags_stretch_ratio = clamp(B.size_flags_stretch_ratio, 0.4, 2)
			C.size_flags_stretch_ratio = clamp(C.size_flags_stretch_ratio, 0.4, 2)


func _on_vertical_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_MASK_LEFT):
			active = true
		
		if !event.is_pressed():
			active = false


func _on_vertical_resize_mouse_exited() -> void:
	if !Input.is_mouse_button_pressed(1):
		active = false

