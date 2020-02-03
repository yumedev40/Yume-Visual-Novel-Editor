tool
extends Tabs

export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var catalog_root_path : NodePath
var catalog_root : Object

export(NodePath) var nametag_color_button_path : NodePath
var nametag_color_button : Object

export(NodePath) var dialogue_color_button_path : NodePath
var dialogue_color_button : Object

export(NodePath) var custom_dialoguebox_field_path : NodePath
var custom_dialoguebox_field : Object

export(NodePath) var dialoguebox_instance_control_path : NodePath
var dialoguebox_instance_control : Object


var nametag_color : Color = Color.white
var dialogue_color : Color = Color.white
var custom_dialoguebox_path : String = ""




#warnings-disable
func _ready() -> void:
	setup_ui()
	
	if nametag_color_button:
		(nametag_color_button as ColorPickerButton).connect("color_changed", self, "new_nametag_color")
	
	if dialogue_color_button:
		(dialogue_color_button as ColorPickerButton).connect("color_changed", self, "new_dialogue_color")
	
	if custom_dialoguebox_field:
		(custom_dialoguebox_field as LineEdit).connect("text_changed", self ,"on_custom_dialoguebox_changed")
		(custom_dialoguebox_field as LineEdit).connect("focus_exited", self ,"on_custom_dialoguebox_focus_exited")



func _setup(data:Dictionary) -> void:
#	print(data)
	if data.has("text"):
		if data["text"].has("nametag_color") && data["text"].has("dialogue_color") && data["text"].has("custom_dialoguebox"):
			# Nametag
			var nt_array : Array = data["text"]["nametag_color"]
			
			nametag_color = Color(nt_array[0], nt_array[1], nt_array[2], nt_array[3])
			
			if nametag_color_button:
				(nametag_color_button as ColorPickerButton).color = Color(nt_array[0], nt_array[1], nt_array[2], nt_array[3])
			
			
			# Dialogue Text
			var dt_array : Array = data["text"]["dialogue_color"]
			
			dialogue_color = Color(dt_array[0], dt_array[1], dt_array[2], dt_array[3])
			
			if dialogue_color_button:
				(dialogue_color_button as ColorPickerButton).color = Color(dt_array[0], dt_array[1], dt_array[2], dt_array[3])
			
			
			# Custom Dialoguebox Path
			custom_dialoguebox_path = data["text"]["custom_dialoguebox"]
			if custom_dialoguebox_field:
				(custom_dialoguebox_field as LineEdit).text = data["text"]["custom_dialoguebox"]
				if data["text"]["custom_dialoguebox"] != "":
					(custom_dialoguebox_field as LineEdit).set("custom_colors/font_color", Color.green)
					
					if dialoguebox_instance_control:
						for i in dialoguebox_instance_control.get_children():
							i.queue_free()
						
						var instanced_dialoguebox : Object = load(data["text"]["custom_dialoguebox"]).instance()
						dialoguebox_instance_control.add_child(instanced_dialoguebox)
						
						(instanced_dialoguebox as Control).size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
						(instanced_dialoguebox as Control).size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
						
						yield(get_tree().create_timer(0.01),"timeout")
						
						instanced_dialoguebox.call_deferred("start_dialogue", "Nametag", "Dialogue Text", false)
					
					
					if dialoguebox_instance_control:
						if dialoguebox_instance_control.get_child_count() > 0:
							dialoguebox_instance_control.get_child(0).dialoguebox.set("custom_colors/default_color", dialogue_color)
			
					if dialoguebox_instance_control:
						if dialoguebox_instance_control.get_child_count() > 0:
							dialoguebox_instance_control.get_child(0).nametag.set("custom_colors/default_color", nametag_color)
				
				else:
					if dialoguebox_instance_control:
						for i in dialoguebox_instance_control.get_children():
							i.queue_free()
		else:
			push_error("Character text parameters are missing, check file for text attributes")
	else:
		push_error("Character text parameters are missing, check if file contains data")
		_reset()



func _reset() -> void:
	nametag_color = Color.white
	dialogue_color = Color.white
	
	if nametag_color_button:
		(nametag_color_button as ColorPickerButton).color = Color.white
	if dialogue_color_button:
		(dialogue_color_button as ColorPickerButton).color = Color.white
	if custom_dialoguebox_field:
		(custom_dialoguebox_field as LineEdit).text = ""
		(custom_dialoguebox_field as LineEdit).set("custom_colors/font_color", null)
	
	if dialoguebox_instance_control:
		for i in dialoguebox_instance_control.get_children():
			i.free()
	
	nametag_color = Color.white
	dialogue_color = Color.white
	custom_dialoguebox_path = ""



func new_nametag_color(new_color:Color) -> void:
	nametag_color = new_color
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["text"]["nametag_color"] = [new_color.r, new_color.g, new_color.b, new_color.a]
		
		if dialoguebox_instance_control:
			if dialoguebox_instance_control.get_child_count() > 0:
				dialoguebox_instance_control.get_child(0).nametag.set("custom_colors/default_color", new_color)



func new_dialogue_color(new_color:Color) -> void:
	dialogue_color = new_color
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["text"]["dialogue_color"] = [new_color.r, new_color.g, new_color.b, new_color.a]
		
		if dialoguebox_instance_control:
			if dialoguebox_instance_control.get_child_count() > 0:
				dialoguebox_instance_control.get_child(0).dialoguebox.set("custom_colors/default_color", new_color)



func on_custom_dialoguebox_changed(new_text:String) -> void:
	custom_dialoguebox_path = new_text
	
	if catalog_root.current_selected:
		var file_check : File = File.new()
		var flag : bool = false
	
		flag = file_check.file_exists(new_text)
		
		if flag:
			match new_text.get_extension():
				"tscn":
					flag = true
				_:
					flag = false
		
		match flag:
			true:
				(custom_dialoguebox_field as LineEdit).set("custom_colors/font_color", Color.green)
				
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["text"]["custom_dialoguebox"] = new_text
				
				for i in dialoguebox_instance_control.get_children():
					i.queue_free()
				
				var instanced_dialoguebox : Object = load(new_text).instance()
				dialoguebox_instance_control.add_child(instanced_dialoguebox)
				
				(instanced_dialoguebox as Control).size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
				(instanced_dialoguebox as Control).size_flags_vertical = VBoxContainer.SIZE_EXPAND_FILL
				
				yield(get_tree().create_timer(0.01),"timeout")
				
				instanced_dialoguebox.call_deferred("start_dialogue", "Nametag", "Dialogue Text", false)
				
#				if "nametag" in instanced_dialoguebox:
#					if instanced_dialoguebox.nametag:
#						(instanced_dialoguebox.nametag as RichTextLabel).bbcode_text = "Nametag"
				
				if dialoguebox_instance_control:
					if dialoguebox_instance_control.get_child_count() > 0:
						dialoguebox_instance_control.get_child(0).nametag.set("custom_colors/default_color", nametag_color)
				
				if dialoguebox_instance_control:
					if dialoguebox_instance_control.get_child_count() > 0:
						dialoguebox_instance_control.get_child(0).dialoguebox.set("custom_colors/default_color", dialogue_color)
				
			_:
				(custom_dialoguebox_field as LineEdit).set("custom_colors/font_color", Color.red)
				
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["text"]["custom_dialoguebox"] = ""
				
				if dialoguebox_instance_control:
					for i in dialoguebox_instance_control.get_children():
						i.queue_free()


func on_custom_dialoguebox_focus_exited() -> void:
	if custom_dialoguebox_field:
		on_custom_dialoguebox_changed(custom_dialoguebox_field.text)








# Helper Methods

func setup_ui() -> void:
	get_object_ref(editor_root_path, "editor_root")
	get_object_ref(catalog_root_path, "catalog_root")
	get_object_ref(nametag_color_button_path, "nametag_color_button")
	get_object_ref(dialogue_color_button_path, "dialogue_color_button")
	get_object_ref(custom_dialoguebox_field_path, "custom_dialoguebox_field")
	get_object_ref(dialoguebox_instance_control_path, "dialoguebox_instance_control")


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
