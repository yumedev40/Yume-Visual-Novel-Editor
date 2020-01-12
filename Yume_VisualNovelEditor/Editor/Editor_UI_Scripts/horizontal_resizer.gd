tool
extends Panel

onready var A : Object
onready var B : Object
export(float, 0, 0.1, 0.001)var damp : float = 0.006

var active : bool = false

var size_flags : Vector2 = Vector2.ZERO
var max_size : float = 0.0


#warnings-disable
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if active && A && B:
			A.size_flags_stretch_ratio += event.relative.x * damp
			B.size_flags_stretch_ratio -= event.relative.x * damp
			
			A.size_flags_stretch_ratio = clamp(A.size_flags_stretch_ratio, 0.4, max_size)
			B.size_flags_stretch_ratio = clamp(B.size_flags_stretch_ratio, 0.4, max_size)


func _on_horizontal_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_MASK_LEFT):
			active = true
		
		if !event.is_pressed():
			active = false


func _on_horizontal_resize_mouse_exited() -> void:
	if !Input.is_mouse_button_pressed(1):
		active = false

func _setup_init_flags() -> void:
	size_flags.x = A.size_flags_stretch_ratio
	size_flags.y = B.size_flags_stretch_ratio
	max_size = max(size_flags.x, size_flags.y)

