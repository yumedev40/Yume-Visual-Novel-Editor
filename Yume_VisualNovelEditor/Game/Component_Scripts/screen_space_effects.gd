tool
extends TextureRect

export(NodePath) var root_path : NodePath
var root : Object

export(Color) var modulate_color : Color = Color.white setget set_modulate_color, get_modulate_color

var modulate_path : String = "shader_param/modulate_color"

var modulation_tween : Tween = Tween.new()




#warnings-disable
func _ready() -> void:
	get_object_ref(root_path, "root")
	
	add_child(modulation_tween)
	
	modulation_tween.connect("tween_completed", self, "_on_modulate_tween_completed")



func _reset() -> void:
	modulation_tween.stop_all()
	self.set_modulate_color(Color.white)
	hide()



func set_modulate_color(col:Color) -> void:
	modulate_color = col
	material.set(modulate_path, col)

func get_modulate_color() -> Color:
	return modulate_color



func modulate_screen(input_color:Color, duration:float, ease_type:int) -> void:
	if !visible:
		show()
	
	if duration > 0.0:
		var start_value : Color
		var end_value : Color
		
		var tween_value : int = 0
		var ease_value : int = 0
		
		start_value = material.get(modulate_path)
		end_value = input_color
		
		match ease_type:
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
		
		modulation_tween.stop_all()
		modulation_tween.interpolate_property(self, "modulate_color", start_value, end_value, duration, tween_value, ease_value)
		modulation_tween.start()
	else:
		self.set_modulate_color(input_color)
		root.emit_signal("success")



func _on_modulate_tween_completed(object:Object, key:NodePath) -> void:
	root.emit_signal("success")



# Helper Methods

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )

