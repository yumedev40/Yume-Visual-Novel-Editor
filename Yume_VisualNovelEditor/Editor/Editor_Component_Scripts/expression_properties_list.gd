tool
extends PanelContainer

onready var root := $"../../.."

onready var expression_name_field := $ScrollContainer/PanelContainer2/VBoxContainer/HBoxContainer/LineEdit

onready var expression_icon_button := $ScrollContainer/PanelContainer2/VBoxContainer/HBoxContainer2/PanelContainer3/HBoxContainer/PanelContainer2/OptionButton

onready var expression_icon_rect := $ScrollContainer/PanelContainer2/VBoxContainer/HBoxContainer2/PanelContainer3/HBoxContainer/PanelContainer/TextureRect2

onready var expression_rid_label := $ScrollContainer/PanelContainer2/VBoxContainer/HBoxContainer/Label

onready var local_animation_transition_options := $ScrollContainer/PanelContainer2/VBoxContainer/HBoxContainer2/OptionButton



var catalog_root : Object

var current_selected : TreeItem




#warnings-disable
func _ready() -> void:
	expression_name_field.connect("text_changed", self, "on_name_text_changed")
	
	expression_icon_button.connect("icon_selected", self, "icon_selected")
	
	local_animation_transition_options.connect("item_selected", self, "local_animation_transition_selected")





func _setup(data:Dictionary) -> void:
	for i in root.stage_visual_anim_buttons:
		(i as OptionButton).select(0)
	
	for i in root.box_visual_anim_buttons:
		(i as OptionButton).select(0)
	
	root.reset_preview_buttons()
	
	
	expression_rid_label.text = current_selected.get_tooltip(0)
	
	expression_name_field.text = data["name"]
	
	expression_icon_rect.texture = load(data["icon"])
	
	local_animation_transition_options.selected = int(data["local_animation_transition_type"])
	
	for i in root.stage_visual_anim_buttons:
		if data.has(i.name):
			if data[i.name].has("animation_menu_index"):
				if int(data[i.name]["animation_menu_index"]) < i.get_item_count():
					(i as OptionButton).select(int(data[i.name]["animation_menu_index"]))
				else:
					(i as OptionButton).select(0)
			else:
				(i as OptionButton).select(0)
			
			if data[i.name].has("animation_menu_text"):
				if data[i.name]["animation_menu_text"].replace(" ", "") != "":
					(i as OptionButton).text = data[i.name]["animation_menu_text"]
		else:
			(i as OptionButton).select(0)
	
	
	for i in root.box_visual_anim_buttons:
		if data.has(i.name):
			if data[i.name].has("animation_menu_index"):
				if int(data[i.name]["animation_menu_index"]) < i.get_item_count():
					(i as OptionButton).select(int(data[i.name]["animation_menu_index"]))
				else:
					(i as OptionButton).select(0)
			else:
				(i as OptionButton).select(0)
			
			if data[i.name].has("animation_menu_text"):
				if data[i.name]["animation_menu_text"].replace(" ", "") != "":
					(i as OptionButton).text = data[i.name]["animation_menu_text"]
		else:
			(i as OptionButton).select(0)
	
	
	for i in root.stage_spinbox_values:
		if data.has(i.name):
			i.value = data[i.name]
		else:
			i.value = root.base_random_value
	
	for i in root.box_spinbox_values:
		if data.has(i.name):
			i.value = data[i.name]
		else:
			i.value = root.base_random_value






func _reset(data:Dictionary) -> void:
	current_selected = null
	
	for i in root.stage_visual_anim_buttons:
		(i as OptionButton).select(0)
	
	for i in root.box_visual_anim_buttons:
		(i as OptionButton).select(0)
	
	root.reset_preview_buttons()





func on_name_text_changed(new_text:String) -> void:
	if is_instance_valid(current_selected):
		current_selected.set_text(0, new_text)
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)]["name"] = new_text
		
		sort_names()


func icon_selected(path:String) -> void:
	if is_instance_valid(current_selected):
		current_selected.set_icon(0, load(path))
	
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)]["icon"] = path


func local_animation_transition_selected(id:int) -> void:
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)]["local_animation_transition_type"] = id








# Helper Methods

func sort_names() -> void:
	var item_array : Array = []
	var item : TreeItem = current_selected.get_parent().get_children()
	
	while is_instance_valid(item):
		item_array.append(item.get_text(0).to_lower())
		item = item.get_next()
	
	item_array.sort()
	
	for i in item_array:
		var names : TreeItem = current_selected.get_parent().get_children()
		
		while is_instance_valid(names):
			if names.get_text(0).to_lower() == i:
				names.move_to_bottom()
			
			names = names.get_next()

