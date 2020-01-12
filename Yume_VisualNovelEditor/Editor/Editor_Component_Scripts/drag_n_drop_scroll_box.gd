tool
extends Panel

export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var menu_fold_button_path : NodePath
var menu_fold_button : Object

var collapse_icon : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/collapse_menu.png")

var expand_icon : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/expand_menu.png")

onready var drop_separator : Object = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Scenes/drop_separator.tscn")

onready var vbox : Object = $"ActionsList"
onready var vbar : Object = $"VScrollBar"

signal vbox_size_changed

export(float, 100, 1000000, 100) var max_v_bar_value : float = 1000000

export(float, 1, 1000, 1) var min_scroll_speed : float = 10
export(float, 1, 1000, 1) var max_scroll_speed : float = 60

export(float) var wheel_step : float = 0.1

var scroll_available : bool = false

var scroll_anim_target : float = 0.0  setget _scroll_anim

signal _vbox_size_changed

var scrollbar_tween : Object = Tween.new()
var scrollbar_width : float = 0.0

var max_drag_scroll_speed : float = 30

# Drag UI Variables
var scene_open : bool = false

var drag_between_timer : Object

var dragged_node : Object
var drop_separator_node : Object



#warnings-disable
func _ready() -> void:
	get_object_ref(editor_root_path, "editor_root")
	get_object_ref(menu_fold_button_path, "menu_fold_button")
	
	drag_between_timer = Timer.new()
	add_child(drag_between_timer)
	
	drag_between_timer.wait_time = 0.2
	drag_between_timer.one_shot = true
	drag_between_timer.connect("timeout", self, "_on_drag_between_timeout")
	
	add_child(scrollbar_tween)
	
	scrollbar_width = vbar.rect_size.x
	
	drop_separator_node = drop_separator.instance()
	drop_separator_node.set_meta("_drop_separator_", true)
	
	connect("mouse_entered", self, "_on_mouse_enter")
	connect("mouse_exited", self, "_on_mouse_exit")
	
	connect("_vbox_size_changed", self, "_vbox_resized")
	connect("resized", self, "_on_resize")
	
	connect("gui_input", self, "_gui_input")
	
	
	vbar.connect("value_changed", self, "_vbar_scrolled")
	
	vbar.hide()


func _input(event: InputEvent) -> void:
#	if event is InputEventKey:
#		if Input.is_key_pressed(KEY_5):
#			printt(vbox, vbox.visible)
#
	if event is InputEventMouseButton:
		if scroll_available:
			if vbar.visible:
				if event.button_index == BUTTON_WHEEL_UP:
					self.scroll_anim_target = vbar.value - clamp((min_scroll_speed / height_ratio()) , min_scroll_speed, max_scroll_speed)
				elif event.button_index == BUTTON_WHEEL_DOWN:
					self.scroll_anim_target = vbar.value + clamp((min_scroll_speed / height_ratio()) , min_scroll_speed, max_scroll_speed)
				elif event.button_index == BUTTON_MIDDLE:
					if event.pressed:
						_scroll_to_bottom()
		
		if get_tree().get_root().gui_get_drag_data():
			if dragged_node:
				dragged_node = null


#func _process(delta: float) -> void:
#	print(drop_separator_node, drop_separator_node.get_parent())


func _gui_input(event:InputEvent) -> void:
	var pos : float = event.position.y
	
	var position_height : float = range_lerp(pos, 0, rect_size.y, 0, 1.0)
	
	if dragged_node:
		if position_height < 0.25:
			var speed : float = range_lerp(position_height, 0, 0.25, 1, 0)
			vbar.value -= (max_drag_scroll_speed * speed) * range_lerp(height_ratio(), 1, 0, 0, 1)
		if position_height > 0.75:
			var speed : float = range_lerp(position_height, 0.75, 1.0, 0, 1)
			vbar.value += (max_drag_scroll_speed * speed) * range_lerp(height_ratio(), 1, 0, 0, 1)
	
	# Drag between behavior
	if get_tree().get_root().gui_get_drag_data():
		if get_tree().get_root().gui_get_drag_data().has_meta("action_node"):
			if !drag_between_timer.time_left > 0.0:
				drag_between_timer.start()


func _on_drag_between_timeout() -> void:
	if !dragged_node:
		dragged_node = get_tree().get_root().gui_get_drag_data()
	
	if !scroll_available:
		dragged_node = null
		
		if drop_separator_node.is_inside_tree():
			var divider : Object
			
			for i in vbox.get_children():
				if i.has_meta("_drop_separator_"):
					divider = i
					break
			
			if divider:
				divider.get_parent().remove_child(divider)



func _scroll_anim(target:float) -> void:
	scroll_anim_target = target
	
	scrollbar_tween.stop_all()
	scrollbar_tween.interpolate_property(vbar, "value", vbar.value, scroll_anim_target, 0.2,Tween.TRANS_EXPO, Tween.EASE_OUT)
	scrollbar_tween.start()


func _vbar_scrolled(value:float) -> void:
	var input_value : float = value
	var value_adjust : float = range_lerp(input_value, 0 , vbar.max_value - vbar.page, 0, vbar.max_value )
	
	vbox.rect_position.y = round(-value_adjust)


func _adjust_scroll_bar(pinned:bool = false) -> void:
	if !height_ratio():
		return
	
	
	if height_ratio() >= 1:
		vbar.hide()
		vbox.rect_size.x = rect_size.x
	else:
		vbar.show()
		vbox.rect_size.x = rect_size.x - (scrollbar_width + 5)
	
	var value_1 : float = vbar.value
	var value_percent_1 : float = range_lerp(value_1, 0, vbar.max_value - vbar.page, 0, 1 )
	
	vbar.max_value = round(clamp(vbox.rect_size.y - rect_size.y, 1, max_v_bar_value))
	vbar.page = round(vbar.max_value * height_ratio())
	
	var value_2 : float = vbar.value
	var value_percent_2 : float = range_lerp(value_2, 0, vbar.max_value - vbar.page, 0, 1 )
	
	var value_difference : float = (value_1 - value_2) * -1
	
	if !pinned:
		if vbar.visible && abs(value_difference) > 0:
			vbar.value = clamp(vbar.value + (vbar.value * value_difference) , 0, max_v_bar_value)
	else:
		var value_3 : float = vbar.value
		var value_percent_3 : float = range_lerp(value_3, 0, vbar.max_value - vbar.page, 0, 1 )
	
		if value_percent_3 != 0:
			if vbar.visible && abs(value_difference) > 0:
				vbar.value = (vbar.max_value - vbar.page) * value_percent_3


func _vbox_resized(scroll_to_bottom:bool = false, pinned:bool = false, scroll_to_top:bool = false) -> void:
	yield (get_tree().create_timer(0.01), "timeout")
	
	var node_count : int = vbox.get_child_count()
	if node_count == 0:
		return
	
	wheel_step = float(1.0) / float(node_count)
	
	vbox.rect_size.y = 0
	
	if vbox.rect_size.y != 0:
		_adjust_scroll_bar(pinned)
	
	if scroll_to_bottom:
		_scroll_to_bottom()
	elif scroll_to_top:
		_scroll_to_top()


func _scroll_to_bottom() -> void:
	vbar.value = vbar.max_value

func _scroll_to_top() -> void:
	vbar.value = 0


func _on_resize() -> void:
	_adjust_scroll_bar()


func _on_mouse_enter() -> void:
	scroll_available = true

func _on_mouse_exit() -> void:
	scroll_available = false
	
#	drag_between_timer.stop()


func height_ratio() -> float:
	if rect_size.y == 0 || vbox.rect_size.y == 0:
		return 1.0
	
	return float(rect_size.y) / float(vbox.rect_size.y)





func _reset() -> void:
	for i in vbox.get_children():
		i.queue_free()
	
	vbar.hide()
	
	_reset_menu_fold_button()


func _reset_menu_fold_button() -> void:
	menu_fold_button.pressed = false
	_on_MenuFoldButtons_toggled(false)



func _clips_input() -> bool:
	return true


func can_drop_data(position: Vector2, data:Object) -> bool:
	var flag : bool = false
	
	if scene_open:
		if !data:
			return false
		
		if !data.has_method("has_meta"):
			return false
		
		if data.has_meta("action_node"):
			flag = true
		
		if data.has_meta("scene_action"):
			flag = true
	
	if !flag:
		if drop_separator_node.is_inside_tree():
			var divider : Object
			
			for i in vbox.get_children():
				if i.has_meta("_drop_separator_"):
					divider = i
					break
			
			if divider:
				divider.get_parent().remove_child(divider)
	
	return flag


func drop_data(position: Vector2, data:GDScript) -> void:
	var node : Object = GDScript.new()
	
	if data:
		node = data.new()
	
		if data.has_meta("action_title"):
			node.action_title = data.get_meta("action_title")
		if data.has_meta("action_description"):
			node.action_description = data.get_meta("action_description")
		if data.has_meta("action_color_theme"):
			node.action_color_theme = data.get_meta("action_color_theme")
		if data.has_meta("action_icon"):
			node.action_icon = data.get_meta("action_icon")
		
		if data.has_meta("action_category"):
	#		node.set_meta("category", data.get_meta("action_category"))
			node.action_category = data.get_meta("action_category")
	#	if data.has_meta("action_icon"):
	#		node.set_meta("action", data.get_meta("action_name"))
		
		_add_scene_node(node)
	else:
		get_tree().queue_delete(node)


func _add_scene_node(scene_node:Object) -> void:
	var divider : Object
	var flag : bool = false
	
	for i in vbox.get_children():
		if i.has_meta("_drop_separator_"):
			vbox.add_child(scene_node)
			vbox.move_child(scene_node, i.get_index())
			
			divider = i
			
			flag = true
			
			emit_signal("_vbox_size_changed", false, true)
			
			break
	
	if !flag:
		vbox.add_child(scene_node)
		scene_node.get_child(0)._add_anim()
		
		emit_signal("_vbox_size_changed", true)
	else:
		divider.get_parent().remove_child(divider)



# Helper Methods

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )


func _on_MenuFoldButtons_toggled(button_pressed: bool) -> void:
	if button_pressed:
		menu_fold_button.set("texture_normal", expand_icon)
	else:
		menu_fold_button.set("texture_normal", collapse_icon)
	
	
	for i in vbox.get_children():
		i.get_child(0)._on_HideButton_toggled(button_pressed)
