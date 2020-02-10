tool
extends Tabs

export(Color) var rid_color : Color
export(Color) var selection_color : Color
export(Color) var selection_text_color : Color

export(NodePath) var catalog_root_path : NodePath
var catalog_root : Object

export(NodePath) var visual_tab_root_path : NodePath
var visual_tab_root : Object

export(NodePath) var expression_properties_path : NodePath
var expression_properties : Object



onready var vresizer := $PanelContainer/VBoxContainer/v_resizer

onready var v_separator := $PanelContainer/VBoxContainer/VSeparator

onready var stage_visual_animations := $PanelContainer/VBoxContainer/Properties/ScrollContainer/PanelContainer2/VBoxContainer/StageVisualAnimationsContainer

onready var dialoguebox_sprite_animations := $PanelContainer/VBoxContainer/Properties/ScrollContainer/PanelContainer2/VBoxContainer/DialogueBoxSpriteAnimationsContainer

onready var expression_list := $PanelContainer/VBoxContainer/Tree

onready var properties_list := $PanelContainer/VBoxContainer/Properties

onready var add_expressions_button := $PanelContainer/VBoxContainer/HBoxContainer/Button


# Internal
const base_random_value : float = 25.0

var stage_visual_anim_buttons : Array = []
var box_visual_anim_buttons : Array = []
var stage_spinbox_values : Array = []
var box_spinbox_values : Array = []
var preview_anim_buttons : Array = []







# Internal
var base_expression_dictionary : Dictionary = {
	"name" : "New Expression",
	"icon" : "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/empty_icon.png",
	"local_animation_transition_type" : 0,
}


var root : TreeItem
var current_selected : TreeItem







# warnings-disable
func _ready() -> void:
	setup_ui()
	build_tree()
	
	expression_list.connect("button_pressed", self, "erase_expression")
	
	v_separator.show()
	properties_list.hide()
	add_expressions_button.disabled = true
	
	# connect ui buttons
	for i in stage_visual_anim_buttons:
		if i is OptionButton:
			i.connect("item_selected", self, "on_mainmenu_item_selected", [i])
	
	for i in box_visual_anim_buttons:
		if i is OptionButton:
			i.connect("item_selected", self, "on_mainmenu_item_selected", [i])
	
	for i in stage_spinbox_values:
		if i is SpinBox:
			i.connect("value_changed", self, "on_random_value_changed", [i])
			
			if i.name.find("random") != -1:
				i.value = base_random_value
	
	for i in box_spinbox_values:
		if i is SpinBox:
			i.connect("value_changed", self, "on_random_value_changed", [i])
			
			if i.name.find("random") != -1:
				i.value = base_random_value
	
	for i in preview_anim_buttons:
		i.connect("pressed", self, "on_preview_anim_pressed", [i])



func _setup(data:Dictionary) -> void:
	if data["visuals"].has("stage_instance_path"):
		if data["visuals"]["stage_instance_path"] != "":
			add_expressions_button.disabled = false
		else:
			add_expressions_button.disabled = true
	else:
		add_expressions_button.disabled = true
	
	setup_animation_selection_ui(data["visuals"])
	
	clear_tree()
	
	hide_properties()
	
	current_selected = null
	properties_list.current_selected = null
	
	build_tree()
	
	if data.has_all(["expressions"]):
		for i in data["expressions"].keys():
			add_expression(false, [ data["expressions"][i]["name"], data["expressions"][i]["icon"], i ])
	else:
		push_error("Character expressions list data is missing")



func _reset() -> void:
	current_selected = null
	properties_list.current_selected = null
	
	clear_tree()
	hide_properties()












func build_tree() -> void:
	root = expression_list.create_item()

func clear_tree() -> void:
	expression_list.clear()
	root = null



func add_expression(add_to_catalog:bool = true, data:Array = []) -> void:
	var item : TreeItem = expression_list.create_item(root)
	var rid : String = ""
	
	if add_to_catalog:
		rid = gen_rid(root)
	
	if data.size() <= 0:
		item.set_text(0, "New Expression")
		item.set_icon(0, load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/empty_icon.png"))
		item.set_icon_max_width(0, 16)
		
		item.add_button(0, load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
		
		item.set_metadata(0, rid)
		item.set_tooltip(0, rid)
	else:
		item.set_text(0, data[0])
		item.set_icon(0, load(data[1]))
		item.set_icon_max_width(0, 16)
		
		item.add_button(0, load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
		
		item.set_metadata(0, data[2])
		item.set_tooltip(0, data[2])
	
	if add_to_catalog:
		if catalog_root:
			if catalog_root.current_selected:
				if !catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)].has("expressions"):
					catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"] = {}
			
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][rid] = base_expression_dictionary.duplicate(true)
	
	sort_names()



func _on_Button_pressed() -> void:
	add_expression()


func erase_expression(item:TreeItem, column:int, id:int) -> void:
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"].erase(item.get_tooltip(0))
	
	root.remove_child(item)
	
	current_selected = null
	properties_list.current_selected = null
	
	hide_properties()


func _on_Tree_item_selected() -> void:
	if is_instance_valid(current_selected):
		current_selected.clear_custom_bg_color(0)
		current_selected.clear_custom_color(0)
	
	current_selected = expression_list.get_selected()
	properties_list.current_selected = expression_list.get_selected()
	
	current_selected.set_custom_bg_color(0, selection_color)
	current_selected.set_custom_color(0, selection_text_color)
	
	display_properties()
	
	
	# Setup properties
	
	properties_list._setup(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)])
	


func _on_Tree_nothing_selected() -> void:
	if is_instance_valid(current_selected):
		current_selected.clear_custom_bg_color(0)
		current_selected.clear_custom_color(0)
	
	current_selected = null
	properties_list.current_selected = null
	
	if expression_list.get_selected():
		expression_list.get_selected().deselect(0)
	
	hide_properties()


func display_properties() -> void:
	if properties_list:
		properties_list.show()
	
	v_separator.hide()


func hide_properties() -> void:
	if properties_list:
		properties_list.hide()
	
	v_separator.show()



func setup_animation_selection_ui(data:Dictionary, clear_flag:int = 0) -> void:
	if !data.has_all(["stage_instance_animation_player_paths", "stage_instance_sprite_frames_paths", "box_sprite_animation_player_paths", "box_sprite_sprite_frames_paths"]):
		data["stage_instance_animation_player_paths"] = []
		data["stage_instance_sprite_frames_paths"] = []
		data["box_sprite_animation_player_paths"] = []
		data["box_sprite_sprite_frames_paths"] = []
	
	match clear_flag:
		0:
			generate_anim_options(data["stage_instance_animation_player_paths"], data["stage_instance_sprite_frames_paths"], stage_visual_anim_buttons, stage_spinbox_values)
			
			generate_anim_options(data["box_sprite_animation_player_paths"], data["box_sprite_sprite_frames_paths"], box_visual_anim_buttons, box_spinbox_values)
		1:
			generate_anim_options(data["stage_instance_animation_player_paths"], data["stage_instance_sprite_frames_paths"], stage_visual_anim_buttons, stage_spinbox_values)
		_:
			generate_anim_options(data["box_sprite_animation_player_paths"], data["box_sprite_sprite_frames_paths"], box_visual_anim_buttons, box_spinbox_values)



func generate_anim_options(anim_players:Array, sprite_frames:Array, button_array:Array, spinbox_value_array:Array) -> void:
	# Clear previous options
	for i in spinbox_value_array:
		i.value = base_random_value
	
	
	for i in button_array:
		if i is OptionButton:
			for x in i.get_popup().get_children():
				if x is PopupMenu:
					x.free()
	
	for i in button_array:
		if i is OptionButton:
			i.clear()
	
	for i in button_array:
		if i is OptionButton:
			i.add_item("No Animation Selected")
			
			if anim_players.size() > 0:
				
				i.get_popup().add_separator("Animation Players")
				
				for x in anim_players:
					var new_submenu : PopupMenu = PopupMenu.new()
					new_submenu.name = x[1]
					new_submenu.set_meta("AnimPlayerPath", x[0])
					
					i.get_popup().add_child(new_submenu)
					new_submenu.connect("id_pressed", self, "submenu_item_selected", [new_submenu])
					
					i.get_popup().add_submenu_item(x[1], x[1])
					
					for z in x[2].size():
						new_submenu.add_item(x[2][z])
			
			if sprite_frames.size() > 0:
				
				i.get_popup().add_separator("Sprite Frames Resources")
				
				for y in sprite_frames:
					var new_submenu : PopupMenu = PopupMenu.new()
					new_submenu.name = y[1]
					new_submenu.set_meta("AnimPlayerPath", y[0])
					
					i.get_popup().add_child(new_submenu)
					new_submenu.connect("id_pressed", self, "submenu_item_selected", [new_submenu])
					
					i.get_popup().add_submenu_item(y[1], y[1])
					
					for z in y[2].size():
						new_submenu.add_item(y[2][z])



func on_mainmenu_item_selected(id:int, menu:Object) -> void:
	# Main ui
	match id:
		0:
			(menu as OptionButton).text = "No Animation Selected"
			
			if catalog_root.current_selected:
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)][menu.name] = {
					"animation_player" : "",
					"animation_name" : "",
					"animation_menu_index" : 0,
					"animation_menu_text" : ""
				}



func submenu_item_selected(id: int, menu:PopupMenu) -> void:
	var selection_index : int = 0
	
	for i in (menu.get_parent().get_parent() as OptionButton).get_popup().get_item_count():
		if (menu.get_parent().get_parent() as OptionButton).get_popup().get_item_text(i) == menu.name:
			(menu.get_parent().get_parent() as OptionButton).select(i)
			
			selection_index = i
	
	var button_text : String = str(menu.name, " > ", menu.get_item_text(id))
	
	(menu.get_parent().get_parent() as OptionButton).text = button_text
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)][menu.get_parent().get_parent().name] = {
			"animation_player" : menu.get_meta("AnimPlayerPath"),
			"animation_name" : menu.get_item_text(id),
			"animation_menu_index" : selection_index,
			"animation_menu_text" : button_text
		}



func on_random_value_changed(value:float, line_edit:Object) -> void:
	if catalog_root.current_selected:
		if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"].has(current_selected.get_tooltip(0)):
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][current_selected.get_tooltip(0)][line_edit.name] = value



func on_preview_anim_pressed(button:Object) -> void:
	var state : bool = button.pressed
	
	for i in preview_anim_buttons:
		if i != button:
			i.pressed = false
	
	if state:
		var neighboring_nodes : Array = all_nodes(button.get_parent())
		
		var anim_path : Array = []
		var stage_category : bool = false
		
		for i in neighboring_nodes:
			if i is OptionButton:
				if i.name.find("animation") != -1:
					anim_path = i.text.split(" > ")
					
					if i.name.find("stage") != -1:
						stage_category = true
					else:
						stage_category = false
					
					break
		
		if anim_path.size() > 1:
			if stage_category:
				play_specified_animation(visual_tab_root.stage_instance_pos_3D, anim_path)
				play_specified_animation(visual_tab_root.stage_instance_pos_2D, anim_path)
			else:
				play_specified_animation(visual_tab_root.box_sprite_3d_container, anim_path)
				play_specified_animation(visual_tab_root.box_sprite_2d_container, anim_path)
		else:
			button.pressed = false
	else:
		stop_instance_animations()




func play_specified_animation(container:Object, animation_data:Array) -> void:
	if container.get_child_count() > 0:
		var instance_nodes : Array = all_nodes(container.get_child(0))
		
		for x in instance_nodes:
			if x.name == animation_data[0]:
				if x is AnimationPlayer:
					if x.is_playing():
						x.stop()
						x.seek(0.0, true)
					
					x.play(animation_data[1])
			else:
				if x is AnimationPlayer:
					if x.is_playing():
						x.stop()
						x.seek(0.0, true)
					
					if x.current_animation != x.autoplay:
						x.current_animation = x.autoplay



func stop_all_animations(container:Object) -> void:
	if container.get_child_count() > 0:
		var instance_nodes : Array = all_nodes(container.get_child(0))
		
		for x in instance_nodes:
			if x is AnimationPlayer:
				if x.is_playing():
					x.stop()
					x.seek(0.0, true)
					
					if x.current_animation != x.autoplay:
						x.current_animation = x.autoplay



func stop_instance_animations() -> void:
	stop_all_animations(visual_tab_root.stage_instance_pos_3D)
	stop_all_animations(visual_tab_root.stage_instance_pos_2D)
	stop_all_animations(visual_tab_root.box_sprite_3d_container)
	stop_all_animations(visual_tab_root.box_sprite_2d_container)



func reset_preview_buttons() -> void:
	stop_instance_animations()
	
	for i in preview_anim_buttons:
		i.pressed = false














# Helper Methods

func setup_ui() -> void:
	vresizer.A = expression_list
	vresizer.B = properties_list
	vresizer.C = v_separator
	
	get_object_ref(expression_properties_path, "expression_properties")
	get_object_ref(catalog_root_path, "catalog_root")
	get_object_ref(visual_tab_root_path, "visual_tab_root")
	
	properties_list.catalog_root = catalog_root
	
	# Get list of anim buttons
	for x in all_nodes($PanelContainer/VBoxContainer/Properties/ScrollContainer/PanelContainer2/VBoxContainer/StageVisualAnimationsContainer):
		if x is OptionButton:
			stage_visual_anim_buttons.append(x)
		elif x is SpinBox:
			stage_spinbox_values.append(x)
		elif x is TextureButton:
			if x.name.find("PreviewButton") != -1:
				preview_anim_buttons.append(x)
	
	for y in all_nodes($PanelContainer/VBoxContainer/Properties/ScrollContainer/PanelContainer2/VBoxContainer/DialogueBoxSpriteAnimationsContainer):
		if y is OptionButton:
			box_visual_anim_buttons.append(y)
		elif y is SpinBox:
			box_spinbox_values.append(y)
		elif y is TextureButton:
			if y.name.find("PreviewButton") != -1:
				preview_anim_buttons.append(y)



func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )


static func gen_rid(tree_root:TreeItem) -> String:
	var rid : String = ""
	var datetime : Dictionary = OS.get_datetime()
	
	var day : int = datetime["day"]
	var weekday : int = datetime["weekday"]
	var month : int = datetime["month"]
	var year : int = datetime["year"]
	var dst : int = int(datetime["dst"])
	var hour : int = datetime["hour"]
	var minute : int = datetime["minute"]
	var second : int = datetime["second"]
	
	randomize()
	
	var second_value : int = second + 1
	
	var random : int = clamp(randi()%10000 + 1, 1, 10000) + randi()%second_value
	
#	var date_id : int = day + month + weekday
#	var time_id : int =  dst + hour + minute
#	var second_id : int = second
	
	rid = str("EX-", year, day, month, weekday, dst, hour, minute, second, "-", random)
	
	var child_items : TreeItem = tree_root.get_children()
	var iterator : int = 1
	
	# Check for duplicates
	while is_instance_valid(child_items):
		if child_items.get_metadata(0):
			var rid_check : String = child_items.get_metadata(0)
			
			if rid_check.replace(" ", "") != "":
				if rid == rid_check:
					rid = str(rid, iterator)
		
		iterator += 1
		
		child_items = child_items.get_next()
	
	return rid


func sort_names() -> void:
	var item_array : Array = []
	var item : TreeItem = root.get_children()
	
	while is_instance_valid(item):
		item_array.append(item.get_text(0).to_lower())
		item = item.get_next()
	
	item_array.sort()
	
	for i in item_array:
		var names : TreeItem = root.get_children()
		
		while is_instance_valid(names):
			if names.get_text(0).to_lower() == i:
				names.move_to_bottom()
			
			names = names.get_next()


func all_nodes(parent:Object) -> Array:
	var nodes : Array = []
	var found_nodes : Array = []
	
	for i in parent.get_children():
		nodes.append(i)
		
		if i.get_children().size() > 0:
			nodes.append(all_nodes(i))
	
	for x in nodes:
		if typeof(x) == TYPE_ARRAY:
			for y in x:
				found_nodes.append(y)
		else:
			found_nodes.append(x)
	
	return found_nodes
