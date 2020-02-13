tool
extends HBoxContainer

onready var scene_action_container : Object = $"../../../../../../../.."
onready var CADM : Object = $"../../../../../../../../CharacterActionsDataManager"

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."
onready var action_list_container : Object = node_container_base.get_parent().get_parent()


onready var character_icon_container : Object = $VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/character_icon_container
var character_icon := preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_Component_Scenes/character_pawn_icon.tscn")


# internal
const preview_name_length : int = 5
enum PLACE {END, START, BETWEEN}

var character_code : String = ""
var character_name : String = ""
var character_stage_rid : String = "N/A"
var character_placement_mode : int = PLACE.END
var between_characters_array : Array = []



#warnings-disable
func _ready() -> void:
	set_meta("character_order_component", true)
	
	# Connect to CADM
	CADM.connect("update_character_data", self, "update_character_data")
	CADM.connect("update_stage_data", self, "update_stage_data")
	
	
	# preview initialization
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Character Entrance":
			$VBoxContainer/HBoxContainer/VBoxContainer/Label.text = "Placement Position"
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("character_order"):
			character_stage_rid = action_node_root.loaded_action_data["character_order"][1]
			character_placement_mode = action_node_root.loaded_action_data["character_order"][3]
			between_characters_array = action_node_root.loaded_action_data["character_order"][4]
	
	if character_stage_rid == "N/A":
		character_stage_rid = gen_rid()




# Main Action Info
func get_action_data() -> Array:
	return [character_code, character_stage_rid, character_name, character_placement_mode, between_characters_array]



func update_list(character_stage_info:Array) -> void:
	# Clear and build icon list display
	yield(get_tree().create_timer(0.002),"timeout")
	
	for i in character_icon_container.get_children():
		i.free()
	
	
	# Setup Character Icons
	var current_flag : bool = false
	
	for i in character_stage_info.size():
		if CADM.character_event_tracker[i] == action_node_root:
#			print(character_stage_info[i][1])
			
			for x in character_stage_info[i][1].size():
				if character_stage_info[i][1][x][0] != character_stage_rid:
					var prev_name : String = character_stage_info[i][1][x][1]
					var stage_rid : String = character_stage_info[i][1][x][0]
					
					add_non_current_node(prev_name, stage_rid)
				else:
					var current_name : String = character_stage_info[i][1][x][1]
					var stage_rid : String = character_stage_info[i][1][x][0]
					
					add_main_node(current_name, stage_rid)
					
					current_flag = true
			
			break
	
	if !current_flag:
		$VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/character_icon_container.modulate = Color.red
	else:
		$VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/character_icon_container.modulate = Color.white




func add_main_node(character_name:String, stage_id:String) -> void:
	var new_char_icon := character_icon.instance()
	new_char_icon.set_meta("_stage_id_", stage_id)
	
	new_char_icon.current = true
	
	if character_name.length() > preview_name_length:
		new_char_icon.set_name( str(character_name.left(preview_name_length), "...") )
	else:
		new_char_icon.set_name( str(character_name) )
	
	new_char_icon.set_tooltip(character_name)
	
	character_icon_container.add_child(new_char_icon)


func add_non_current_node(previous_name:String, stage_id:String) -> void:
	var prev_char_icon := character_icon.instance()
	prev_char_icon.set_meta("_stage_id_", stage_id)
	
	prev_char_icon.current = false
	
	if previous_name.length() > preview_name_length:
		prev_char_icon.set_name( str(previous_name.left(preview_name_length), "...") )
	else:
		prev_char_icon.set_name( str(previous_name) )
	
	prev_char_icon.set_tooltip(previous_name)
	
	character_icon_container.add_child(prev_char_icon)












func update_character_data(new_data:Dictionary) -> void:
	pass


func update_stage_data(new_data:Array) -> void:
	update_list(new_data)














## Helper Method


#func update_character_nodes() -> void:
#	for i in get_parent().get_children():
#		if i.has_meta("character_order_component"):
#			i.update_list()
#
#	yield(get_tree().create_timer(0.001),"timeout")
#
#	for i in action_list_container.get_children():
#		if i.get_index() != action_node_root.get_index():
#			if i.name.find("Character Entrance") != -1:
#				for x in i.find_node("UI", true, false).get_children():
#					if x.has_meta("character_order_component"):
#						print("updating character info")
#						x.update_list()


func get_character_entrance_info(action:Object) -> Array:
	for i in action.find_node("UI", true, false).get_children():
		if i.has_meta("character_order_component"):
			return i.get_action_data()
	return []


static func gen_rid() -> String:
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
	
	rid = str("SC-", year, day, month, weekday, dst, hour, minute, second, "-", random)
	
	return rid
