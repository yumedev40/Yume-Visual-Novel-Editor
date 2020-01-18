tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

onready var color_preview : Object = $"VBoxContainer2/HBoxContainer2/PanelContainer/ColorRect"

onready var preview_slider : Object = $"VBoxContainer2/HBoxContainer2/PanelContainer/VBoxContainer/PreviewSlider"

onready var preview_button : Object = $"VBoxContainer2/HBoxContainer2/VBoxContainer/PreviewButton"

onready var duration_box : Object = $"VBoxContainer2/HBoxContainer/SpinBox"

var transition_direction : bool = true

enum EASE {LINEAR, IN, OUT, IN_OUT, OUT_IN, ELASTIC, BOUNCE}

var ease_type : int = EASE.LINEAR

var preview_tween : Tween = Tween.new()

var color : Color = Color.white

var duration : float = 1.0


# internal vars
var mouse_over : bool = true





#warnings-disable
func _ready() -> void:
	set_meta("transition_settings", true)
	
	add_child(preview_tween)
	preview_tween.connect("tween_completed", self, "_preview_completed")
	preview_tween.connect("tween_step", self, "_preview_tween_step")
	
	color_preview.color = Color.black
	
	duration_box.get_line_edit().connect("focus_entered", self, "_on_spinbox_focus_entered")
	
	$VBoxContainer2/HBoxContainer/SpinBox.value = 1
	
	$VBoxContainer2/HBoxContainer2/PanelContainer/VBoxContainer/PreviewSlider.value = 100.0
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Fade Screen":
			for i in get_parent().get_children():
				if i.has_meta("color_picker"):
#					color_preview.set_start = true
					color_preview.set_color(i.color)
		"Modulate Scene Color":
			for i in get_parent().get_children():
				if i.has_meta("color_picker"):
#					color_preview.set_start = true
					color_preview.set_color(i.color)
			
			color_preview.set_modulate_ = true
			
			$VBoxContainer2/HBoxContainer2/PanelContainer/VBoxContainer/PreviewSlider.value = 0.0
			
			$VBoxContainer2/HBoxContainer/Direction.selected = 0
			transition_direction = false
			
			color_preview.set_start = true
			
			$VBoxContainer2/HBoxContainer/Direction.hide()
			$VBoxContainer2/HBoxContainer/Label.hide()
			$VBoxContainer2/HBoxContainer/HSeparator.hide()
			$VBoxContainer2/HBoxContainer/HSeparator3.hide()
			$VBoxContainer2/HBoxContainer/HSeparator5.hide()
		"Backdrop":
			$VBoxContainer2/HBoxContainer/SpinBox.value = 0.5
			
			$VBoxContainer2/HBoxContainer2/PanelContainer/VBoxContainer/PreviewSlider.value = 0.0
			
			$VBoxContainer2/HBoxContainer/Direction.selected = 0
			transition_direction = false
			
			color_preview.set_start = true
			
			color_preview.set_image_flag(true)
			
			$VBoxContainer2/HBoxContainer/Direction.hide()
			$VBoxContainer2/HBoxContainer/Label.hide()
			$VBoxContainer2/HBoxContainer/HSeparator.hide()
			$VBoxContainer2/HBoxContainer/HSeparator3.hide()
			$VBoxContainer2/HBoxContainer/HSeparator5.hide()
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("transition_settings"):
			match action_node_root.loaded_action_data["transition_settings"][0]:
				true:
					$VBoxContainer2/HBoxContainer2/PanelContainer/VBoxContainer/PreviewSlider.value = 100.0
					
					$VBoxContainer2/HBoxContainer/Direction.selected = 0
					
					node_container_base.flip_preview_ramp()
				_:
					$VBoxContainer2/HBoxContainer2/PanelContainer/VBoxContainer/PreviewSlider.value = 0.0
					
					$VBoxContainer2/HBoxContainer/Direction.selected = 1
					
					node_container_base.flip_preview_ramp(false)
					
					color_preview.set_start = true
			
			transition_direction = bool(action_node_root.loaded_action_data["transition_settings"][0])
			
			ease_type = int(action_node_root.loaded_action_data["transition_settings"][1])
			
			$VBoxContainer2/HBoxContainer/Ease_Type.selected = int(action_node_root.loaded_action_data["transition_settings"][1])
			
			$VBoxContainer2/HBoxContainer/SpinBox.value = action_node_root.loaded_action_data["transition_settings"][2]
			
			duration = action_node_root.loaded_action_data["transition_settings"][2]



# Main Action Info
func get_action_data() -> Array:
	return [transition_direction, ease_type, duration]




func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !mouse_over:
			duration_box.release_focus()
			duration_box.get_line_edit().release_focus()
			
			if duration_box.get_line_edit().is_connected("mouse_entered", self, "on_mouse_entered"):
				duration_box.get_line_edit().disconnect("mouse_entered", self, "on_mouse_entered")
			if duration_box.get_line_edit().is_connected("mouse_exited", self, "on_mouse_exited"):
				duration_box.get_line_edit().disconnect("mouse_exited", self, "on_mouse_exited")
			
			mouse_over = true
			
			set_process_input(false)



func _on_Direction_item_selected(ID: int) -> void:
	match ID:
		0:
			transition_direction = true
			preview_slider.value = 100.0
			node_container_base.flip_preview_ramp()
			color_preview.adjust_transparency(Color.black)
		1:
			transition_direction = false
			preview_slider.value = 0.0
			node_container_base.flip_preview_ramp(false)
			color_preview.adjust_transparency(Color.white)

func _on_SpinBox_value_changed(value: float) -> void:
	if is_processing_input():
		mouse_over = false
	
	set_duration()

func _on_SpinBox_changed() -> void:
	if is_processing_input():
		mouse_over = false
	
	set_duration()

func _on_Ease_Type_item_selected(ID: int) -> void:
	ease_type = ID


func set_duration() -> void:
	duration = $VBoxContainer2/HBoxContainer/SpinBox.value



func _on_Preview_pressed() -> void:
	var tween_value : int = 0
	var ease_value : int = 0
	
	var start_value : float = 0.0
	var end_value : float = 0.0
	
	var start_color : Color
	var end_color : Color
	
	if preview_button.pressed:
		if transition_direction:
			start_value = 100.0
			end_value = 0.0
			
			start_color = color.inverted()
			end_color = color
		else:
			start_value = 0.0
			end_value = 100.0
			
			start_color = color
			end_color = color.inverted()
		
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
		
		if duration <= 0.0:
			duration = 0.01
		
		preview_tween.stop_all()
		preview_tween.interpolate_property(preview_slider, "value", start_value, end_value, duration, tween_value, ease_value)
		preview_tween.interpolate_property(color_preview, "color", start_color, end_color, duration, tween_value, ease_value)
		preview_tween.start()
	else:
		preview_tween.stop_all()
		
		if transition_direction:
			preview_slider.value = 100.0
		else:
			preview_slider.value = 0.0
		
		color_preview.color = color.inverted()


func _preview_completed(object:Object, key:NodePath) -> void:
	if transition_direction:
		preview_slider.value = 100.0
	else:
		preview_slider.value = 0.0
	
	preview_button.pressed = false
	color_preview.color = color.inverted()
	
	if transition_direction:
		color_preview.adjust_transparency(Color.black)
	else:
		color_preview.adjust_transparency(Color.white)

func _preview_tween_step(object:Object, key:NodePath, elapsed:float, value:Object) -> void:
	color_preview.adjust_transparency(color_preview.color)

func _on_PreviewSlider_value_changed(value: float) -> void:
	pass

func on_mouse_entered() -> void:
#	print("over")
	mouse_over = true

func on_mouse_exited() -> void:
#	print("exited")
	mouse_over = false



func _on_spinbox_focus_entered() -> void:
	if !duration_box.get_line_edit().is_connected("mouse_entered", self, "on_mouse_entered"):
		duration_box.get_line_edit().connect("mouse_entered", self, "on_mouse_entered")
	if !duration_box.get_line_edit().is_connected("mouse_exited", self, "on_mouse_exited"):
		duration_box.get_line_edit().connect("mouse_exited", self, "on_mouse_exited")
	
	set_process_input(true)

