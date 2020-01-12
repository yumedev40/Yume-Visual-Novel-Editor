tool
extends VBoxContainer

var editor_root : Object

onready var hide_button : Object = get_node("HBoxContainer/PanelContainer2/HBoxContainer/HideButton")

onready var action_list : Object = get_node("ActionList")

onready var node_container : Object = get_node("ActionList/NodeContainer")

onready var menu_tween : Object = get_node("Tween")


var up_arrow : StreamTexture = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/up_arrow.png")

var down_arrow : StreamTexture = preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/down_arrow.png")


var menu_hidden : bool = false

var menu_max_size : float = 50.0




#warnings-disable
func _ready() -> void:
	hide_button.connect("pressed", self, "_on_hide_button_pressed")
	
	menu_tween.connect("tween_completed", self, "_on_menu_tween_complete")
	
	set_menu_max_size()
	
	editor_root = $"..".editor_root


func set_menu_max_size() -> void:
	if action_list:
		menu_max_size = node_container.rect_size.y
		node_container.rect_min_size.y = menu_max_size
		clamp(menu_max_size, 50, 1000)

func set_title(title:String) -> void:
	get_node("HBoxContainer/PanelContainer/NodeListTitle").text = title

func get_title() -> String:
	return get_node("HBoxContainer/PanelContainer/NodeListTitle").text

func set_description(description:String) -> void:
	get_node("HBoxContainer/PanelContainer/NodeListTitle").hint_tooltip = description

func set_color_theme(color:Color) -> void:
	get_node("HBoxContainer/PanelContainer").self_modulate = color
	
	if round((color.r + color.g + color.b) * 0.33) > 0.5:
		get_node("HBoxContainer/PanelContainer/NodeListTitle").set("custom_colors/font_color", Color.black)
	else:
		get_node("HBoxContainer/PanelContainer/NodeListTitle").set("custom_colors/font_color", Color.white)


func get_color_theme() -> Color:
	if get_node_or_null("HBoxContainer/PanelContainer"):
		return get_node("HBoxContainer/PanelContainer").self_modulate
	else:
		return Color.white


func menu_anim(flag:bool) -> void:
	if !flag:
		if node_container:
			node_container.hide()
		
		menu_hidden = true
		
		if menu_tween && action_list:
			menu_tween.stop_all()
			
			menu_tween.interpolate_property(action_list, "rect_min_size", action_list.rect_min_size, Vector2(action_list.rect_min_size.x, 0), 0.07, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			
			menu_tween.start()
	else:
		if action_list:
			action_list.show()
		
		menu_hidden = false
		
		if menu_tween && action_list:
			menu_tween.stop_all()
			
			menu_tween.interpolate_property(action_list, "rect_min_size", action_list.rect_min_size, Vector2(action_list.rect_min_size.x, menu_max_size), 0.07, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			
			menu_tween.start()



func _on_menu_tween_complete(object:Object, key:String) -> void:
	if !menu_hidden:
		if node_container:
			node_container.show()
	else:
		if action_list:
			action_list.hide()


func _on_hide_button_pressed() -> void:
	if hide_button:
		if hide_button.pressed:
			menu_anim(false)
			if down_arrow:
				hide_button.texture_normal = down_arrow
		else:
			menu_anim(true)
			if up_arrow:
				hide_button.texture_normal = up_arrow