tool
extends VBoxContainer

onready var close_button : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CloseButton"

onready var hide_button : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/HideButton"

onready var raise_button : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/ToggleButton2"

onready var lower_button : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/ToggleButton3"

onready var preview_icon : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewIcon"

onready var preview_textbox : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewLabel"

onready var character_name_preview_label : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName"

onready var character_dialogue_preview_label : Object = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue"

onready var node_container : Object = $"HBoxContainer/VBoxContainer/PanelContainer2/UI"

onready var menu_tween : Object = $"Tween2"

onready var fade_tween : Object = $"Tween3"

onready var body_panel : Object = $"HBoxContainer/VBoxContainer/PanelContainer2"

onready var scene_node_container : Object = get_parent().get_parent().get_parent()

onready var vbox : Object = get_parent().get_parent()

onready var parent : Object = get_parent()

var up_arrow : Texture = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/up_arrow.png")
var down_arrow : Texture = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/down_arrow.png")

var delete_tween : Object = Tween.new()

# Internal Variables
var preview_available : bool = false
var color_preview : bool = false
var ramp_preview : bool = false
var character_name_preview : bool = false
var character_dialogue_preview : bool = false
var image_preview : bool = false

var menu_hidden : bool = false
var menu_max_size : float = 0

var rearranged : bool = false setget _dim_menu

# Signals
signal menu_hidden




#warnings-disable
func _ready() -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/PreviewRamp.material = $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/PreviewRamp.material.duplicate()
	
	add_child(delete_tween)
	
	close_button.connect("pressed", self, "_on_close_button_pressed")
	
	delete_tween.connect("tween_completed", self, "_delete_tween_done")
	
	menu_tween.connect("tween_completed", self, "_on_menu_tween_complete")
	
	raise_button.connect("pressed", self, "_on_raise_button")
	lower_button.connect("pressed", self, "_on_lower_button")
	
	connect("gui_input", self, "_gui_input")
	
	
	if !get_parent() is Viewport:
		set_title(get_parent().action_title)
		set_description(get_parent().action_description)
		set_color_theme(get_parent().action_color_theme)
		set_icon(get_parent().action_icon)
	
	set_menu_max_size()
	
	connect("menu_hidden", self, "on_menu_hidden", [menu_hidden])
	
	_add_anim()



func set_menu_max_size() -> void:
	if !body_panel:
		body_panel = $"HBoxContainer/VBoxContainer/PanelContainer2"
	
	menu_max_size = body_panel.rect_size.y
	body_panel.rect_min_size.y = menu_max_size


func menu_anim(flag:bool) -> void:
	if !node_container:
		node_container = $"HBoxContainer/VBoxContainer/PanelContainer2/UI"
		menu_tween = $"Tween2"
		body_panel = $"HBoxContainer/VBoxContainer/PanelContainer2"
	
	if menu_max_size == 0:
		set_menu_max_size()
	
	
	if !flag:
		node_container.hide()
		
		menu_hidden = true
		menu_tween.stop_all()
		
		menu_tween.interpolate_property(body_panel, "rect_min_size", body_panel.rect_min_size, Vector2(body_panel.rect_min_size.x, 0), 0.07, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
		menu_tween.start()
	else:
		body_panel.show()
		
		menu_hidden = false
		menu_tween.stop_all()
		
		menu_tween.interpolate_property(body_panel, "rect_min_size", body_panel.rect_min_size, Vector2(body_panel.rect_min_size.x, menu_max_size), 0.07, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
		menu_tween.start()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == 0:
			if !event.pressed:
				_clear_drop_ui()


func set_title(title:String) -> void:
	get_node("HBoxContainer/VBoxContainer/HBoxContainer/NodeTag/HBoxContainer/Label").text = title

func set_color_theme(color:Color) -> void:
	get_node("HBoxContainer/VBoxContainer/HBoxContainer/NodeTag").self_modulate = Color(color.r, color.g, color.b, 1.0)
	
	if round((color.r + color.g + color.b) * 0.33) > 0.5:
		get_node("HBoxContainer/VBoxContainer/HBoxContainer/NodeTag/HBoxContainer/Label").set("custom_colors/font_color", Color.black)
	else:
		get_node("HBoxContainer/VBoxContainer/HBoxContainer/NodeTag/HBoxContainer/Label").set("custom_colors/font_color", Color.white)

func set_description(description:String) -> void:
	get_node("HBoxContainer/VBoxContainer/HBoxContainer/NodeTag").hint_tooltip = description

func set_icon(icon:StreamTexture) -> void:
	get_node("HBoxContainer/VBoxContainer2/HBoxContainer/Icon").texture = icon
	var color : Color = get_parent().action_color_theme
	get_node("HBoxContainer/VBoxContainer2/HBoxContainer/Icon").modulate = Color(color.r, color.g, color.b, 1.0)



func _on_raise_button() -> void:
	if parent.get_index() != 0:
		vbox.move_child(parent, parent.get_index() - 1)
		_shift_anim()

func _on_lower_button() -> void:
	if parent.get_index() != vbox.get_child_count() - 1:
		vbox.move_child(parent, parent.get_index() + 1)
		_shift_anim()

func _shift_anim() -> void:
	fade_tween.stop_all()
	fade_tween.interpolate_property(self, "modulate", Color(1,1,1,0.1), Color(1,1,1,1), 0.4,Tween.TRANS_EXPO, Tween.EASE_OUT)
	fade_tween.start()


func _on_close_button_pressed() -> void:
	close_button.disabled = true
	
	hide_button.pressed = true
	_on_HideButton_toggled(true)
	
	delete_tween.stop_all()
	delete_tween.interpolate_property(self, "modulate", Color.white, Color(1,1,1,0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	delete_tween.start()


func _delete_tween_done(object:Object, key:NodePath) -> void:
	scene_node_container.emit_signal("_vbox_size_changed", false, true)
	
	if !parent is VBoxContainer:
		parent.queue_free()





func on_menu_hidden(flag:bool) -> void:
	pass


func _on_HideButton_pressed() -> void:
	pass


func _on_menu_tween_complete(object:Object, key:String) -> void:
	if !menu_hidden:
		node_container.show()
	else:
		body_panel.hide()
	
	scene_node_container._vbox_resized(false, true)


func _dim_menu(flag:bool) -> void:
	if rearranged != flag:
		rearranged = flag
		
		if flag:
			fade_tween.stop_all()
			fade_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0.5), 0.3,Tween.TRANS_ELASTIC, Tween.EASE_OUT)
			fade_tween.start()
		else:
			fade_tween.stop_all()
			fade_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), 0.3,Tween.TRANS_EXPO, Tween.EASE_OUT)
			fade_tween.start()


func _clear_drop_ui() -> void:
	if rearranged:
		if scene_node_container.drop_separator_node.get_parent():
			vbox.move_child(parent, scene_node_container.drop_separator_node.get_index())
			
			scene_node_container.drop_separator_node.get_parent().remove_child(scene_node_container.drop_separator_node)
			
			_dropped_anim()
		
		self.rearranged = false
		scene_node_container.dragged_node = null
		
		scene_node_container.emit_signal("_vbox_size_changed", false, true)


func _gui_input(event:InputEvent) -> void:
#	print(event)
#
	if event is InputEventMouseMotion:
		if scene_node_container.dragged_node && !rearranged:
			var pos : float = event.position.y
			
			var position_height : float = range_lerp(pos, 0, rect_size.y, 0, 1.0)
			
			if position_height < 0.25:
				if !scene_node_container.drop_separator_node.get_parent():
					
					var flag : bool = false
					var valid : bool = false
					
					if parent.get_index() > 0:
						flag = true
					
					if !flag:
						valid = true
					else:
						if !vbox.get_child( vbox.get_child(parent.get_index() - 1).get_index() ).get_child(0).rearranged:
							valid = true
					
					if flag && valid:
						vbox.add_child_below_node( vbox.get_child(parent.get_index() - 1), scene_node_container.drop_separator_node )
					elif !flag && valid:
						vbox.add_child( scene_node_container.drop_separator_node )
						vbox.move_child( scene_node_container.drop_separator_node, 0 )
					
					scene_node_container.emit_signal("_vbox_size_changed", false, true)
			elif position_height > 0.75:
				if !scene_node_container.drop_separator_node.get_parent():
					
					var flag : bool = false
					var valid : bool = false
					
					if parent.get_index() < vbox.get_child_count() - 1:
						flag = true
					
					if !flag:
						valid = true
					else:
						if !vbox.get_child( vbox.get_child(parent.get_index() + 1).get_index() ).get_child(0).rearranged:
							valid = true
					
					if flag && valid:
						vbox.add_child_below_node( parent, scene_node_container.drop_separator_node )
						scene_node_container.drop_separator_node.show()
					elif !flag && valid:
						vbox.add_child( scene_node_container.drop_separator_node )
						scene_node_container.drop_separator_node.show()
					
					scene_node_container.emit_signal("_vbox_size_changed", false, true)
			else:
				if scene_node_container.drop_separator_node.get_parent():
					scene_node_container.drop_separator_node.get_parent().remove_child(scene_node_container.drop_separator_node)
		elif scene_node_container.dragged_node:
			if scene_node_container.drop_separator_node.get_parent():
				scene_node_container.drop_separator_node.get_parent().remove_child(scene_node_container.drop_separator_node)


func _dropped_anim() -> void:
	fade_tween.stop_all()
	fade_tween.interpolate_property(self, "modulate", Color(1,1,1,0.0), Color(1,1,1,1), 0.6,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	fade_tween.start()
	
	
#	if !hide_button.pressed:
#		node_container.hide()
#
#		body_panel.show()
#
#		menu_hidden = false
#		menu_tween.stop_all()
#
#		menu_tween.interpolate_property(body_panel, "rect_min_size", Vector2(body_panel.rect_min_size.x, 0), Vector2(body_panel.rect_min_size.x, menu_max_size), 0.07, Tween.TRANS_LINEAR, Tween.EASE_OUT)
#
#		menu_tween.start()
		
#		hide_button.pressed = false
#		hide_button.texture_normal = up_arrow


func _add_anim() -> void:
	fade_tween.stop_all()
	fade_tween.interpolate_property(self, "modulate", Color(1,1,1,0.0), Color(1,1,1,1), 0.3,Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	fade_tween.start()


func _on_HideButton_toggled(button_pressed: bool) -> void:
	if !hide_button:
		hide_button = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/HideButton"
	
	if !down_arrow || !up_arrow:
		up_arrow = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/up_arrow.png")
		down_arrow = load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/down_arrow.png")
	
#	if hide_button.pressed:
	if button_pressed:
		hide_button.pressed = true
		menu_anim(false)
		hide_button.texture_normal = down_arrow
		set_preview(true)
		
		if color_preview:
			preview_color_visibility(true)
		if ramp_preview:
			preview_ramp_visibility(true)
		if character_name_preview  || character_dialogue_preview:
			preview_character_dialogue_visiblity(true)
		if image_preview:
			preview_image(true)
		
	else:
		hide_button.pressed = false
		menu_anim(true)
		hide_button.texture_normal = up_arrow
		set_preview(false)
		preview_color_visibility(false)
		preview_ramp_visibility(false)
		preview_character_dialogue_visiblity(false)
		preview_image(false)


func set_preview(flag:bool, preview_text = null, preview_icon_texture = null, clear_bit_flag = 0) -> void:
	if preview_available:
		if !preview_icon || !preview_textbox:
			preview_icon = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewIcon"
			preview_textbox = $"HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewLabel"
		
		if preview_icon_texture:
			preview_icon.texture = preview_icon_texture
		
		if preview_text:
			preview_textbox.set_bbcode(preview_text)
			preview_textbox.hint_tooltip = preview_text
		
		match clear_bit_flag:
			2:
				preview_icon.texture = null
			4:
				preview_textbox.set_bbcode("")
				preview_textbox.hint_tooltip = null
			8:
				preview_icon.texture = null
				preview_textbox.set_bbcode("")
				preview_textbox.hint_tooltip = null
		
		if !flag:
			preview_icon.hide()
			preview_textbox.hide()
		else:
			preview_icon.show()
			
			if preview_textbox.get_bbcode() != "":
				preview_textbox.show()


func preview_color_visibility(hide:bool) -> void:
	if !hide:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer.hide()
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer.show()

func set_preview_color(color:Color = Color.white) -> void:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer/PreviewColor.color = color


func preview_ramp_visibility(hide:bool) -> void:
	if !hide:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2.hide()
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2.show()

func flip_preview_ramp(flip:bool = true) -> void:
	if flip:
		var flag : bool = false
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/PreviewRamp.material.set("shader_param/flip", flag)
	else:
		var flag : bool = true
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/PreviewRamp.material.set("shader_param/flip", flag)

func set_preview_ramp(color_a:Color = Color.black, color_b:Color = Color.darkgray) -> void:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/PreviewRamp.material.set("shader_param/start_color", color_a)
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PanelContainer2/PreviewRamp.material.set("shader_param/end_color", color_b)


func preview_character_dialogue_visiblity(hide:bool) -> void:
	if !hide:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.hide()
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.hide()
	else:
		if $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.text != "" || $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.bbcode_text != "":
			$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.show()
		
		if $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.text != "" || $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.bbcode_text != "":
			$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.show()
		
		if $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.visible && $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.visible:
			$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/HSeparator6.hide()
		else:
			$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/HSeparator6.show()

func set_character_name(new_name:String) -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.bbcode_text = new_name
	
	if $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.rect_min_size.x < 200.0:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.rect_min_size.x = $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.bbcode_text.length() * 8.0
	
	$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.hint_tooltip = $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.text

func set_dialogue_text(new_text:String, placeholder:bool = false) -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.bbcode_text = new_text
	
	$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.hint_tooltip = str("[ ", $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterName.text, " ]\n", $HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.text)
	
	if placeholder:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.set("custom_colors/default_color", Color.fuchsia)
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/CharacterDialogue.set("custom_colors/default_color", null)


func preview_image(hide:bool) -> void:
	if !hide:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewImage.hide()
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewImage.show()

func set_preview_image(_image_:StreamTexture) -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/PreviewImage.texture = _image_







func get_drag_data(position: Vector2) -> Object:
	var node_preview : Object = HBoxContainer.new()
	node_preview.name = "NodePreview"
	
	var node_icon : Object = get_node("HBoxContainer/VBoxContainer2").duplicate(true)
	var node_body : Object = get_node("HBoxContainer/VBoxContainer/HBoxContainer").duplicate(true)
	
	node_body.get_node("PanelContainer2/HBoxContainer/PreviewLabel").show()
	node_body.get_node("PanelContainer2/HBoxContainer/HideButton").hide()
	node_body.get_node("PanelContainer2/HBoxContainer/VBoxContainer").hide()
	node_body.get_node("PanelContainer2/HBoxContainer/CloseButton").hide()
	node_body.get_node("PanelContainer2").hide()
	
	node_body.rect_size.x = 0
	node_body.rect_min_size.x = 200
	
	node_preview.modulate = Color(1,1,1,0.7)
	
	node_preview.add_child(node_icon)
	node_preview.add_child(node_body)
	
	set_drag_preview(node_preview)
	
	var data : Object = parent.duplicate(true)
	data.set_meta("scene_action", true)
	
	self.rearranged = true
	
	scene_node_container.dragged_node = data
	
	return data



func _clips_input() -> bool:
	return true
