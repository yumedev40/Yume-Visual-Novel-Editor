tool
extends HBoxContainer

onready var scene_action_container : Object = $"../../../../../../../.."
onready var CADM : Object = $"../../../../../../../../CharacterActionsDataManager"

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."
onready var action_list_container : Object = node_container_base.get_parent().get_parent()

onready var character_list : Object = $VBoxContainer/HBoxContainer/character_list


# internal
var use_scene_character_data : bool = false

var mouse_over : bool = true

var text_string : String = ""

var character_code : String = ""

var dialogue_box_path : String = ""

var alias_index : int = -1

var character_info : Dictionary = {}





#warnings-disable
func _ready() -> void:
	set_meta("text_string_component", true)
	
	# preview initialization
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Expressed Line":
			$VBoxContainer/HBoxContainer/Label.text = "Speaker Name"
			node_container_base.character_name_preview = true
			
			# Connect to CADM
			CADM.connect("update_character_data", self, "update_character_data")
			
		"Character Entrance":
			$VBoxContainer/HBoxContainer/Label.text = "New Character"
			node_container_base.character_name_preview = true
			$VBoxContainer/HBoxContainer/variables_list.hide()
			
			# Connect to CADM
			CADM.connect("update_character_data", self, "update_character_data")
			
		"Character Exit":
			$VBoxContainer/HBoxContainer/Label.text = "Remove Character"
			node_container_base.character_name_preview = true
			$VBoxContainer/HBoxContainer/variables_list.hide()
			
			# Connect to CADM
			CADM.connect("update_character_data", self, "update_character_data")
			
			# Use scene character data from CADM in character button
			use_scene_character_data = true
	
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("text_string"):
			text_string = action_node_root.loaded_action_data["text_string"][0]
			$VBoxContainer/HBoxContainer/LineEdit.text = action_node_root.loaded_action_data["text_string"][0]
			node_container_base.set_character_name(action_node_root.loaded_action_data["text_string"][0])
			
			character_code = action_node_root.loaded_action_data["text_string"][1]
			
			dialogue_box_path = action_node_root.loaded_action_data["text_string"][2]
			
			alias_index = action_node_root.loaded_action_data["text_string"][3]



# Main Action Info
func get_action_data() -> Array:
	return [text_string, character_code, dialogue_box_path, alias_index]




func _on_LineEdit_text_changed(new_text: String) -> void:
	_on_LineEdit_text_entered(new_text)


func _on_LineEdit_text_entered(new_text: String) -> void:
	text_string = new_text
	node_container_base.set_character_name(new_text)
	
	character_code = ""
	dialogue_box_path = ""
	
	CADM.generate_state_list()








func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed && !mouse_over:
			$VBoxContainer/HBoxContainer/LineEdit.release_focus()
			mouse_over = true
			set_process(false)
	elif event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER):
			$VBoxContainer/HBoxContainer/LineEdit.release_focus()
			mouse_over = true
			set_process(false)

func _on_LineEdit_focus_entered() -> void:
	set_process_input(true)

func _on_LineEdit_mouse_entered() -> void:
	mouse_over = true

func _on_LineEdit_mouse_exited() -> void:
	mouse_over = false



func on_character_list_selected() -> void:
	character_info = character_list.update_character_list(use_scene_character_data)



func on_character_list_item_chosen(id:int, main_character_menu:PopupMenu) -> void:
	var new_text : String = main_character_menu.get_item_text(id)
	
	text_string = new_text
	if !use_scene_character_data:
		character_code = main_character_menu.get_item_metadata(id)
	else:
		character_code = main_character_menu.get_item_metadata(id)[0]
	
	if !use_scene_character_data:
		alias_index = id - 1
	else:
		alias_index = main_character_menu.get_item_metadata(id)[1]
	
	if !use_scene_character_data:
		dialogue_box_path = character_info[main_character_menu.get_item_metadata(id)]["text"]["custom_dialoguebox"]
	
	node_container_base.set_character_name(new_text)
	$VBoxContainer/HBoxContainer/LineEdit.text = new_text
	
	yield(get_tree().create_timer(0.001),"timeout")
	
	CADM.generate_state_list()


func on_alias_submenu_item_chosen(id:int, character_menu:PopupMenu) -> void:
	var new_text : String = character_menu.get_item_text(id)
	
	text_string = new_text
	character_code = character_menu.get_item_metadata(id)
	alias_index = id - 1
	
	dialogue_box_path = character_info[character_menu.get_item_metadata(id)]["text"]["custom_dialoguebox"]
	
	node_container_base.set_character_name(new_text)
	$VBoxContainer/HBoxContainer/LineEdit.text = new_text
	
	yield(get_tree().create_timer(0.001),"timeout")
	
	CADM.generate_state_list()








func update_character_data(new_data:Dictionary) -> void:
	pass
