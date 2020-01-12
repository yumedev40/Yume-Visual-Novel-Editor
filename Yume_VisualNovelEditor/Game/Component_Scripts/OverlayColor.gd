tool
extends ColorRect

export(NodePath) var root_path : NodePath
var root : Object

var tween : Tween = Tween.new()



#warnings-disable
func _ready() -> void:
	get_object_ref(root_path, "root")
	
	add_child(tween)
	
	tween.connect("tween_completed", self, "_on_tween_completed")

func _reset() -> void:
	tween.stop_all()
	color = Color.black
	hide()


func fade_overlay(transition_direction:bool, overlay_color:Color, duration:float, ease_type:int, blend:bool) -> void:
	var blend_ignore : bool = false
	
	if !visible:
		blend_ignore = true
		show()
	
	if duration > 0.0:
		var start_value : Color
		var end_value : Color
		
		var tween_value : int = 0
		var ease_value : int = 0
		
		if transition_direction:
			if !blend:
				start_value = overlay_color
			elif !blend_ignore:
				start_value = color
			else:
				start_value = overlay_color
			
			end_value = Color(overlay_color.r, overlay_color.g, overlay_color.b, 0.0)
		else:
			if !blend:
				start_value = Color(overlay_color.r, overlay_color.g, overlay_color.b, 0.0)
			elif !blend_ignore:
				start_value = Color(color.r, color.g, color.b, 0.0)
			else:
				start_value = Color(overlay_color.r, overlay_color.g, overlay_color.b, 0.0)
				
			end_value = overlay_color
		
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
		
		tween.stop_all()
		tween.interpolate_property(self, "color", start_value, end_value, duration, tween_value, ease_value)
		tween.start()
	else:
		color = overlay_color
		root.emit_signal("success")



func _on_tween_completed(object:Object, key:NodePath) -> void:
	if color.a <= 0.0:
		hide()
	
	root.emit_signal("success")



# Helper Methods

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )

