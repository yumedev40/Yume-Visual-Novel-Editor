tool
extends TextureRect

export(NodePath) var root_path : NodePath
var root : Object

export(float, 0.0, 1.0, 0.1) var transition_amount : float = 0.0 setget set_ab_transition_amount, get_ab_transition_amount

export(StreamTexture) var image_a : StreamTexture setget set_image_a, get_image_a

export(StreamTexture) var image_b : StreamTexture setget set_image_b, get_image_b

export(float, 0.0, 1.0, 0.1) var modulate_amount : float = 0.0 setget set_modulate_amount, get_modulate_amount

export(Color) var modulate_color : Color = Color.white setget set_modulate_color, get_modulate_color


# tweens
var transition_tween : Tween = Tween.new()


# shader vars
var shader : Object

var transition_var_path : String = "shader_param/transition_amount"

var image_a_var_path : String = "shader_param/image_a"

var image_b_var_path : String = "shader_param/image_b"

var modulate_value_var_path : String = "shader_param/modulate_amount"

var modulate_color_var_path : String = "shader_param/modulate_color"


# internal
var clear_image : bool = false






#warnings-disable
func _ready() -> void:
	get_object_ref(root_path, "root")
	
	shader = material
	
	add_child(transition_tween)
	
	transition_tween.connect("tween_all_completed", self, "_on_transition_completed")



func _reset() -> void:
	transition_tween.reset_all()
	transition_tween.free()
	
	transition_tween = Tween.new()
	add_child(transition_tween)
	transition_tween.connect("tween_all_completed", self, "_on_transition_completed")
	
	set_image_a(null)
	set_image_b(null)
	transition_amount = 0.0
	modulate_amount = 0.0
	modulate_color = Color.white
	clear_image = false


func transition_backdrop(new_image:StreamTexture, settings:Array) -> void:
	var speed : float = 1.0
	var tween_value : int = 0
	var ease_value : int = 0
	
	var start : float = 0.0
	var end : float = 1.0
	
	if settings:
		speed = float(settings[2])
		
		match settings[1]:
			0:
				tween_value = Tween.TRANS_LINEAR
				ease_value = Tween.TRANS_LINEAR
			1:
				tween_value = Tween.TRANS_CUBIC
				ease_value = Tween.EASE_IN
			2:
				tween_value = Tween.TRANS_CUBIC
				ease_value = Tween.EASE_OUT
			3:
				tween_value = Tween.TRANS_CUBIC
				ease_value = Tween.EASE_IN_OUT
			4:
				tween_value = Tween.TRANS_CUBIC
				ease_value = Tween.EASE_OUT_IN
			5:
				tween_value = Tween.TRANS_ELASTIC
				ease_value = Tween.EASE_OUT
			6:
				tween_value = Tween.TRANS_BOUNCE
				ease_value = Tween.EASE_IN
	
	
	if !get_image_a() && !get_image_b():
			set_image_a(null)
			set_image_b(new_image)
	else:
		match transition_amount:
			1.0:
				if get_image_b():
					if new_image:
						set_image_a(new_image)
						set_image_b(get_image_b())
					else:
						clear_image = true
						
						set_image_a(null)
						set_image_b(get_image_b())
					
					start = 1.0
					end = 0.0
			0.0:
				if get_image_a():
					if new_image:
						set_image_a(get_image_a())
						set_image_b(new_image)
					else:
						clear_image = true
						
						set_image_a(get_image_a())
						set_image_b(null)
					
					start = 0.0
					end = 1.0
	
	transition_amount = start
	
	if speed > 0.0:
		transition_tween.stop_all()
		transition_tween.interpolate_property(self, "transition_amount", start, end, speed, tween_value, ease_value)
		transition_tween.start()
	else:
		if start == 1.0:
			set_ab_transition_amount(0.0)
		else:
			set_ab_transition_amount(1.0)
		
		root.emit_signal("success")




func _on_transition_completed() -> void:
	if clear_image:
		set_image_a(null)
		set_image_b(null)
		clear_image = false
		self.transition_amount = 0.0
	
	root.emit_signal("success")




#setget
func set_ab_transition_amount(value:float) -> void:
	transition_amount = value
	material.set(transition_var_path, value)

func get_ab_transition_amount() -> float:
	return transition_amount


func set_image_a(image:StreamTexture) -> void:
	image_a = image
	material.set(image_a_var_path, image)
	
	if image_a:
		material.set("shader_param/image_a_empty", false)
	else:
		material.set("shader_param/image_a_empty", true)

func get_image_a() -> StreamTexture:
	return image_a

func set_image_b(image:StreamTexture) -> void:
	image_b = image
	material.set(image_b_var_path, image)
	
	if image_b:
		material.set("shader_param/image_b_empty", false)
	else:
		material.set("shader_param/image_b_empty", true)

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








# Helper Methods

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )



