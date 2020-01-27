tool
extends Tabs

export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var catalog_root_path : NodePath
var catalog_root : Object

export(NodePath) var name_field_path : NodePath
var name_field : Object

export(NodePath) var description_field_path : NodePath
var description_field : Object

var character_name : String
var description : String

# Internal
signal character_name_change_request




#warnings-disable
func _ready() -> void:
	setup_ui()
	
	connect("character_name_change_request", catalog_root, "_on_name_change_request")
	
	name_field.connect("text_entered", self, "on_name_text_entered")
	
	name_field.connect("focus_exited", self, "on_name_text_entered")
	
	description_field.connect("text_changed", self, "on_description_text_changed")



func _setup(data:Dictionary) -> void:
	if data.has("profile"):
		if data["profile"].has("name") && data["profile"].has("description"):
			# Set Name
			character_name = data["profile"]["name"]
			
			if name_field:
				(name_field as LineEdit).text = data["profile"]["name"]
			
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["profile"]["name"] = data["profile"]["name"]
			
			# Set Description
			description = data["profile"]["description"]
			
			if description_field:
				(description_field as TextEdit).text = data["profile"]["description"]
			
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["profile"]["description"] = data["profile"]["description"]
		else:
			push_error("Character profile is missing necessary data, check file for name and description fields")
	else:
		push_error("Character profile is missing, check if file contains data")
		_reset()



func _reset() -> void:
	(name_field as LineEdit).text = "New Character"
	(description_field as TextEdit).text = ""



func on_name_text_entered(new_name:String = "") -> void:
	if new_name == "":
		if (name_field as LineEdit).text != "":
			var text_name : String = (name_field as LineEdit).text
			
			emit_signal("character_name_change_request", text_name)
			character_name = text_name
			
			if catalog_root.current_selected:
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["profile"]["name"] = text_name
			
			return
	
	emit_signal("character_name_change_request", new_name)
	character_name = new_name
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["profile"]["name"] = new_name




func on_description_text_changed() -> void:
	description = description_field.text
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["profile"]["description"] = description_field.text




# Helper Methods

func setup_ui() -> void:
	get_object_ref(editor_root_path, "editor_root")
	get_object_ref(catalog_root_path, "catalog_root")
	get_object_ref(name_field_path, "name_field")
	get_object_ref(description_field_path, "description_field")


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
