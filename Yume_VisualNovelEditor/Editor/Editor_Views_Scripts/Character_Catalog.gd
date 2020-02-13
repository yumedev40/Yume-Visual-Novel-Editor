tool
extends Tabs

onready var editor_root : Object = $"../../.."

var CADM : Object

export(Color) var core_color : Color
export(Color) var extras_color : Color
export(Color) var rid_color : Color

var root : TreeItem
var core_list : TreeItem
var extras_list : TreeItem

var current_selected : TreeItem

var base_char_structure : Dictionary = {
	
	"profile":  {
		"name": "",
		"description": "",
		"aliases": []
		},
	
	"text": {
		"nametag_color": [1,1,1,1],
		"custom_dialoguebox": "",
		"dialogue_color": [1,1,1,1]
		},
	
	"visuals": {
		"stage_instance_path": "",
		"stage_instance_animation_player_paths": [],
		"stage_instance_sprite_frames_paths": [],
		
		"box_sprite_dimensions": {
			"x": 256,
			"y": 256
		},
		"box_sprite_dimensions_proportional": true,
		"box_sprite_transparent": false,
		"box_sprite_instance_path": "",
		"box_sprite_frame_image": "",
		"box_sprite_mask_image": "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png",
		"box_sprite_mask_preset": 0,
		
		"box_sprite_animation_player_paths": [],
		"box_sprite_sprite_frames_paths": [],
		
		},
	
	"expressions": {
	}
	
	}


# internal
var character_dictionary : Dictionary = {} setget update_character_dictionary





# warnings-disable
func _ready() -> void:
	setup_ui()
	
	CADM = $"../Story Editor".find_node("CharacterActionsDataManager", true, false)
	
	$HBoxContainer/PanelContainer/VBoxContainer/Tree.connect("item_selected", self, "on_item_selected")
	$HBoxContainer/PanelContainer/VBoxContainer/Tree.connect("nothing_selected", self, "on_nothing_selected")
	$HBoxContainer/PanelContainer/VBoxContainer/Tree.connect("button_pressed", self, "on_item_deleted")



func _setup() -> void:
	hide_details_tabs()
	build_character_list()
	sort_names()



func _reset() -> void:
#	hide_details_tabs()
	$HBoxContainer/PanelContainer/VBoxContainer/Tree.clear()
	clear_ui()
	self.character_dictionary.clear()



func update_character_dictionary(char_dict:Dictionary) -> void:
	character_dictionary = char_dict
	if CADM:
		CADM.character_dictionary = char_dict



func clear_ui() -> void:
	if $HBoxContainer/PanelContainer/VBoxContainer/Tree.get_selected():
		$HBoxContainer/PanelContainer/VBoxContainer/Tree.get_selected().deselect(0)
		$HBoxContainer/PanelContainer/VBoxContainer/Tree.get_selected().deselect(1)
	
	hide_details_tabs()



func clear_data() -> void:
	var tabs : TabContainer = $HBoxContainer/PanelContainer2/CharacterDataTabs
	
	for i in tabs.get_children():
		if i.has_method("_reset"):
			i._reset()



func save(file_path:String) -> void:
	# Save Character Catalog
	var character_array : Array = []
	var item : TreeItem = root.get_children()
	
	while is_instance_valid(item):
		character_array.append( [item.get_text(1), item.get_text(0)] )
		item = item.get_next()
	
	var file_check : File = File.new()
	if file_check.file_exists(file_path):
		file_check.open(file_path, file_check.WRITE)
		
		for i in character_array:
			file_check.store_line(to_json(i))
		
		file_check.close()
	
	# Save Character Files
	for i in character_dictionary.keys():
		var char_file : File = File.new()
		var filepath : String = str(editor_root.project_directory, "/story_data/character_files/", i, ".ychar")
		
		char_file.open(filepath, char_file.WRITE)
		
		char_file.store_line(to_json(character_dictionary[i]))
		
		char_file.close()



func _on_NewCharacter_pressed() -> void:
	var new_character : TreeItem = $HBoxContainer/PanelContainer/VBoxContainer/Tree.create_item(root)
	var rid : String = gen_rid(root)
	
	new_character.set_text(0, "New Character")
	
	new_character.set_text(1, rid)
	new_character.set_custom_color(1, rid_color)
	new_character.set_tooltip(1, str("RID [", rid, "]"))
	new_character.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
	
	self.character_dictionary[rid] = base_char_structure.duplicate(true)
	self.character_dictionary[rid]["profile"]["name"] = "New Character"
	
	sort_names()



func on_item_deleted(tree_item:TreeItem, Column:int, ID:int) -> void:
	character_dictionary.erase(tree_item.get_text(1))
	
	root.remove_child(tree_item)
	
	hide_details_tabs()
	
	sort_names()



func on_item_selected() -> void:
	if is_instance_valid(current_selected):
		current_selected.clear_custom_bg_color(0)
		current_selected.clear_custom_bg_color(1)
	
	current_selected = $HBoxContainer/PanelContainer/VBoxContainer/Tree.get_selected()
	
	$HBoxContainer/PanelContainer/VBoxContainer/Tree.get_selected().set_custom_bg_color(0, Color8(106, 158, 234))
	$HBoxContainer/PanelContainer/VBoxContainer/Tree.get_selected().set_custom_bg_color(1, Color8(106, 158, 234))
	
	# Setup Tabs
	$HBoxContainer/PanelContainer2/CharacterDataTabs.current_tab = 0
	$HBoxContainer/PanelContainer2/CharacterDataTabs.show()
	var tabs : TabContainer = $HBoxContainer/PanelContainer2/CharacterDataTabs
	
	for i in tabs.get_children():
		if i.has_method("_setup"):
#			var file_check : File = File.new()
#			var filepath : String = str(editor_root.project_directory, "/story_data/character_files/", current_selected.get_text(1), ".ychar")
#
#			if file_check.file_exists(filepath):
#				var data : Dictionary
#
#				file_check.open(filepath, file_check.READ)
#
#				while !file_check.eof_reached():
#					var line : String = file_check.get_line()
#					if line:
#						data = parse_json(line)
#
#				file_check.close()
#
#				if typeof(data) == TYPE_DICTIONARY:
#			clear_data()
#			yield(get_tree().create_timer(0.001),"timeout")
			i._setup(character_dictionary[current_selected.get_text(1)]) 
#					return
#			else:
#				clear_data()
#				return
#		else:
#			clear_data()



func on_nothing_selected() -> void:
	if is_instance_valid(current_selected):
		current_selected.clear_custom_bg_color(0)
		current_selected.clear_custom_bg_color(1)
		current_selected.deselect(0)
		current_selected.deselect(1)
		current_selected = null
	
	clear_ui()



func _on_name_change_request(new_name:String) -> void:
	if current_selected:
		current_selected.set_text(0, new_name)
	
	sort_names()



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



func build_character_list() -> void:
	root = $HBoxContainer/PanelContainer/VBoxContainer/Tree.create_item()
	
	root.set_text(0, "Root")
	
	var file_check : File = File.new()
	
	if file_check.file_exists(str(editor_root.project_directory, "/story_data/character_data", ".yvndata")):
		var file_data_array : Array = []
		
		file_check.open(str(editor_root.project_directory, "/story_data/character_data", ".yvndata"), File.READ)
		
		while !file_check.eof_reached():
			var line : String = file_check.get_line()
			
			if line:
				if line != "":
					file_data_array.append(parse_json(line))
		
		file_check.close()
		
		# Construct Character Tree
		if file_data_array.size() > 0:
			for i in file_data_array:
				if typeof(i) == TYPE_ARRAY:
					var char_item : TreeItem = $HBoxContainer/PanelContainer/VBoxContainer/Tree.create_item(root)
					char_item.set_text(0, i[1])
					char_item.set_text(1, i[0])
					
					char_item.set_custom_color(1, rid_color)
					
					char_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
					
					# Populate local character data dictionary
					self.character_dictionary[i[0]] = base_char_structure.duplicate(true)
					
					var char_file_check : File = File.new()
					var filepath : String = str(editor_root.project_directory, "/story_data/character_files/", i[0], ".ychar")
					
					if char_file_check.file_exists(filepath):
						var data : Dictionary
						
						char_file_check.open(filepath, char_file_check.READ)
						
						while !char_file_check.eof_reached():
							var line : String = char_file_check.get_line()
							if line:
								data = parse_json(line)
						
						char_file_check.close()
						
						if typeof(data) == TYPE_DICTIONARY:
							self.character_dictionary[i[0]] = data






# helper methods
func hide_details_tabs() -> void:
	$HBoxContainer/PanelContainer2/CharacterDataTabs.current_tab = 0
	$HBoxContainer/PanelContainer2/CharacterDataTabs.hide()
	clear_data()


func setup_ui() -> void:
	$HBoxContainer/horizontal_resize3.A = $HBoxContainer/PanelContainer
	$HBoxContainer/horizontal_resize3.B = $HBoxContainer/PanelContainer2
	$HBoxContainer/horizontal_resize3._setup_init_flags()
	
	$HBoxContainer/PanelContainer2/CharacterDataTabs.hide()


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
	
	rid = str("C-", year, day, month, weekday, dst, hour, minute, second, "-", random)
	
	var child_items : TreeItem = tree_root.get_children()
	var iterator : int = 1
	
	# Check for duplicates
	while is_instance_valid(child_items):
		var rid_check : String = child_items.get_text(1)
		
		if rid_check.replace(" ", "") != "":
			if rid == rid_check:
				rid = str(rid, iterator)
		
		iterator += 1
		
		child_items = child_items.get_next()
	
	return rid
