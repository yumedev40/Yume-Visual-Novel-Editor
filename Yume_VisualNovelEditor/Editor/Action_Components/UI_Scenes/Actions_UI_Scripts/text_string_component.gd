tool
extends HBoxContainer

onready var scene_action_container : Object = $"../../../../../../../.."
onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

onready var character_list : Object = $VBoxContainer/HBoxContainer/character_list

# internal
var mouse_over: bool = true

var text_string : String = ""

var character_code : String = ""

var dialogue_box_path : String = ""

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
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("text_string"):
			text_string = action_node_root.loaded_action_data["text_string"][0]
			$VBoxContainer/HBoxContainer/LineEdit.text = action_node_root.loaded_action_data["text_string"][0]
			node_container_base.set_character_name(action_node_root.loaded_action_data["text_string"][0])
			
			character_code = action_node_root.loaded_action_data["text_string"][1]
			
			dialogue_box_path = action_node_root.loaded_action_data["text_string"][2]
	
	
	
	
	character_list.connect("pressed", self, "on_character_list_selected")
	character_list.get_popup().connect("id_pressed", self, "on_character_list_item_chosen", [character_list.get_popup()])



# Main Action Info
func get_action_data() -> Array:
	return [text_string, character_code, dialogue_box_path]



func _on_LineEdit_text_changed(new_text: String) -> void:
	text_string = new_text
	node_container_base.set_character_name(new_text)
	
	character_code = ""
	dialogue_box_path = ""

func _on_LineEdit_text_entered(new_text: String) -> void:
	text_string = new_text
	node_container_base.set_character_name(new_text)
	
	character_code = ""
	dialogue_box_path = ""






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
	character_info = scene_action_container.editor_root.editor_root.get_parent().get_node("Character Catalog").character_dictionary
	
	character_list.get_popup().clear()
	for x in character_list.get_popup().get_children():
		if x is PopupMenu:
			x.free()
	
	for c in character_info:
		if character_info[c]["profile"]["aliases"].size() <= 0:
			character_list.get_popup().add_item(character_info[c]["profile"]["name"])
			
			character_list.get_popup().set_item_metadata(character_list.get_popup().get_item_count() - 1, c)
			character_list.get_popup().set_item_tooltip(character_list.get_popup().get_item_count() - 1, c)
		else:
			var alias_menu : PopupMenu = PopupMenu.new()
			alias_menu.name = character_info[c]["profile"]["name"]
			
			character_list.get_popup().add_child(alias_menu)
			alias_menu.connect("id_pressed", self, "on_alias_submenu_item_chosen", [alias_menu])
			
			character_list.get_popup().add_submenu_item(character_info[c]["profile"]["name"], character_info[c]["profile"]["name"])
			character_list.get_popup().set_item_metadata(character_list.get_popup().get_item_count() - 1, c)
			character_list.get_popup().set_item_tooltip(character_list.get_popup().get_item_count() - 1, c)
			
			
			alias_menu.add_item(character_info[c]["profile"]["name"])
			alias_menu.set_item_metadata(alias_menu.get_item_count() - 1, c)
			
			for a in character_info[c]["profile"]["aliases"]:
				alias_menu.add_item(a)
				alias_menu.set_item_metadata(alias_menu.get_item_count() - 1, c)


func on_character_list_item_chosen(id:int, main_character_menu:PopupMenu) -> void:
	var new_text : String = main_character_menu.get_item_text(id)
	
	text_string = new_text
	
	character_code = main_character_menu.get_item_metadata(id)
	
	dialogue_box_path = character_info[main_character_menu.get_item_metadata(id)]["text"]["custom_dialoguebox"]
	
	node_container_base.set_character_name(new_text)
	$VBoxContainer/HBoxContainer/LineEdit.text = new_text


func on_alias_submenu_item_chosen(id:int, character_menu:PopupMenu) -> void:
	var new_text : String = character_menu.get_item_text(id)
	
	text_string = new_text
	character_code = character_menu.get_item_metadata(id)
	
	dialogue_box_path = character_info[character_menu.get_item_metadata(id)]["text"]["custom_dialoguebox"]
	
	node_container_base.set_character_name(new_text)
	$VBoxContainer/HBoxContainer/LineEdit.text = new_text

