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

export(NodePath) var alias_field_path : NodePath
var alias_field : Object

var character_name : String
var description : String

# Internal
signal character_name_change_request




#warnings-disable
func _ready() -> void:
	setup_ui()
	
	connect("character_name_change_request", catalog_root, "_on_name_change_request")
	
	name_field.connect("text_changed", self, "on_name_text_entered")
	
	name_field.connect("text_entered", self, "on_name_text_entered")
	
	name_field.connect("focus_exited", self, "on_name_text_entered")
	
	description_field.connect("text_changed", self, "on_description_text_changed")
	
	(alias_field as TextEdit).connect("text_changed", self, "on_alias_text_changed")



func _setup(data:Dictionary) -> void:
	# Set Aliases
	if alias_field:
		(alias_field as TextEdit).text = ""
	
	
#	print("setup")
	if data.has("profile"):
		if data["profile"].has("name") && data["profile"].has("description") && data["profile"].has("aliases"):
			
			# Set Name
			character_name = data["profile"]["name"]
			
			if name_field:
				(name_field as LineEdit).text = data["profile"]["name"]
			
			
			# Set Description
			description = data["profile"]["description"]
			
			if description_field:
				(description_field as TextEdit).text = data["profile"]["description"]
			
			
			# Set Aliases
			if alias_field:
				for i in data["profile"]["aliases"].size():
					if i < data["profile"]["aliases"].size()-1:
						(alias_field as TextEdit).text = (alias_field as TextEdit).text + data["profile"]["aliases"][i] + "\n"
					else:
						(alias_field as TextEdit).text = (alias_field as TextEdit).text + data["profile"]["aliases"][i]
			
		else:
			push_error("Character profile is missing necessary data, check file for name, description, and aliases fields")
	else:
		push_error("Character profile is missing, check if file contains data")
		_reset()



func _reset() -> void:
#	print("reset")
	(name_field as LineEdit).text = "New Character"
	(description_field as TextEdit).text = ""
	
	character_name = ""
	description = ""
	
	(alias_field as TextEdit).text = ""



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



func on_alias_text_changed() -> void:
	var alias_list : Array = []
	
	if alias_field:
		for i in (alias_field as TextEdit).get_line_count():
			alias_list.append((alias_field as TextEdit).get_line(i))
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["profile"]["aliases"] = alias_list





# Helper Methods

func setup_ui() -> void:
	get_object_ref(editor_root_path, "editor_root")
	get_object_ref(catalog_root_path, "catalog_root")
	get_object_ref(name_field_path, "name_field")
	get_object_ref(description_field_path, "description_field")
	get_object_ref(alias_field_path, "alias_field")


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
