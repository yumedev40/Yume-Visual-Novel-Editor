tool
extends Control

onready var backdrop = $"VISUAL_COMPONENTS/Backdrop"

onready var overlay_color = $"VISUAL_COMPONENTS/OverlayScreen/OverlayColor"

onready var screen_space_fx = $"VISUAL_COMPONENTS/ScreenSpaceEffects"


var raw_edit_preview : bool = false
var debug_mode : bool = false
var waiting_for_input : bool = false

var skip_index : int = 0 setget skip_to_index, get_skip_index

var progress_position : PoolIntArray = [1,1] setget set_progress_position, get_progress_position


# Internal Variables
var action_tags : Array = [] setget set_actions_array, get_actions_array

enum ACTION_STATE {NULL, RUNNING, FAILED, SUCCESS}
var current_action : String = ""
var current_action_state : int = 0


# Signals
signal success
signal failure
signal completed



#warnings-disable
func _ready() -> void:
	set_process(false)
	
	connect("success", self, "on_action_success")
	connect("failure", self, "on_action_failure")
	
	
	if !debug_mode && !Engine.is_editor_hint():
#		var auto_load_flag: bool = false
#		var ps : Array = ProjectSettings.get_property_list()
#		for i in ps:
#			if (i["name"] as String).find("autoload") != -1:
#				if i["name"] == "autoload/yume_game_controller":
#					auto_load_flag = true
		
		if get_node_or_null("/root/yume_game_controller"):
			if  get_node("/root/yume_game_controller").initial_scene == "":
				preview_complete_scene([1,1], get_initial_file())
			else:
				print("start from specific file")
	
	
#	if !debug_mode && !Engine.is_editor_hint():
#		if yume_game_controller.initial_scene == "":
##			print("start from beginning")
#			preview_complete_scene([1,1], get_initial_file())
#		else:
#			print("start from specific file")


func _reset() -> void:
	var nodes : Array = _filter_array(_get_object_child_nodes(self))
	for i in nodes:
		if i.has_method("_reset"):
			i.call_deferred("_reset")



func preview() -> void:
	pass


func _process(delta:float) -> void:
	pass






# SetGet Methods
func set_progress_position(progress:PoolIntArray) -> void:
	progress_position = progress

func get_progress_position() -> PoolIntArray:
	return progress_position



func skip_to_index(index:int) -> void:
	skip_index = index

func get_skip_index() -> int:
	return skip_index



func set_actions_array(actions:Array) -> void:
	action_tags = actions

func get_actions_array() -> Array:
	return action_tags






# Connected Methods
func on_action_success() -> void:
#	print("action succeeded")
	
	if debug_mode && !raw_edit_preview:
		action_tags.pop_front()
		update_action_state()
	elif !debug_mode:
		action_tags.pop_front()
		update_action_state()


func on_action_failure() -> void:
#	print("action failed")
	
	if debug_mode && !raw_edit_preview:
		action_tags.pop_front()
		update_action_state()
	elif !debug_mode:
		action_tags.pop_front()
		update_action_state()






# Call Preview Scene From Editor
func preview_complete_scene(chapter_scene:Array, filepath:String) -> void:
	progress_position = [chapter_scene[0], chapter_scene[1]]
	
#	print(filepath)
	
	parse_file(filepath)
	update_action_state()



func update_action_state() -> void:
	if action_tags.size() > 0:
		current_action = action_tags[0]["action"]
		current_action_state = ACTION_STATE.RUNNING
		call_action_stack()
	else:
		current_action = ""
		current_action_state = ACTION_STATE.NULL
		emit_signal("completed")
		_reset()





# Shared Methods
func parse_file(filepath:String) -> void:
	var file : File = File.new()
	
	var tag_array : Array = []
	
	if file.file_exists(filepath):
		file.open(filepath, File.READ)
		
		var tag = file.get_line()
		
		while !file.eof_reached():
			tag_array.append(parse_json(tag))
			tag = file.get_line()
		
		file.close()
	else:
		push_error(str("Could not parse scene action file", filepath))
	
	action_tags = tag_array






# Action Pushdown Automata
func call_action_stack() -> void:
	match current_action.to_lower():
		"backdrop":
			var image_path : String
			var transition_info : Array = []
			var instant : bool
			var new_image : StreamTexture
			
			if action_tags[0].has("image") && action_tags[0].has("transition_settings") && action_tags[0].has("toggle"):
				image_path = action_tags[0]["image"][0]
				transition_info = action_tags[0]["transition_settings"]
				instant = action_tags[0]["toggle"][0]
				
				if action_tags[0]["toggle"][0]:
					transition_info[2] = 0.0
			else:
				push_warning(str(current_action, " is missing one of the following components: [image][transition_settings][toggle] -- action failed"))
				emit_signal("failure")
				return
			
			if image_path != "":
				backdrop.transition_backdrop(load(image_path), transition_info)
			else:
				backdrop.transition_backdrop(null, transition_info)
		
		"breakpoint":
			if !Engine.is_editor_hint() && !debug_mode:
				breakpoint
			else:
				printerr("Breakpoint")
			emit_signal("success")
		
		"debug":
			print("Basic debug test node")
			emit_signal("success")
		
		"dialogue box visibility":
			# Dialogue box reference
			var dialogue_box : Object = $UI_COMPONENTS/DialogueBox_UI/Dialogue_Box
			
			var visibility : bool
			var reset_flag : bool
			
			if action_tags[0].has("toggle"):
				visibility = action_tags[0]["toggle"][0]
				reset_flag = action_tags[0]["toggle"][1]
				
				dialogue_box.reset_on_hide = reset_flag
				dialogue_box.set_box_visibility(visibility)
			else:
				push_warning(str(current_action, " is missing one of the following components: [toggle] -- action failed"))
				emit_signal("failure")
				return
		
		"end":
			var filepath : String
			
			if action_tags[0].has("scene"):
				filepath = action_tags[0]["scene"][0]
			else:
				push_warning(str(current_action, " is missing one of the following components: [scene] -- action failed"))
				emit_signal("failure")
				return
			
			match filepath:
				"":
					if !debug_mode:
						var game_controller : Object
						
						if get_node_or_null("/root/yume_game_controller"):
							game_controller = get_node("/root/yume_game_controller")
						else:
							push_warning("Yume game controller singleton missing -- action_failed")
							emit_signal("failure")
							return
						
						var main_menu_path : String = str(game_controller.directory_paths["project_directory"], "/game_scenes/main_menu/Main_Menu.tscn")
						
						get_tree().change_scene(main_menu_path)
					else:
						push_warning(str("End of story called -- would return to main menu"))
						
						emit_signal("success")
				_:
					if !debug_mode:
						get_tree().change_scene(str(filepath))
					else:
						push_warning(str("End of story called -- would change to destination scene ", filepath))
						
						emit_signal("success")
		
		"expressed line":
			# Dialogue box reference
			var dialogue_box : Object = $UI_COMPONENTS/DialogueBox_UI/Dialogue_Box
			var name_string : String
			var dialogue_string : String
			
			
			if action_tags[0].has("text_box") && action_tags[0].has("text_string"):
				name_string = action_tags[0]["text_string"][0]
				match action_tags[0]["text_box"][1]:
					true:
						dialogue_string = action_tags[0]["text_box"][2]
					false:
						dialogue_string = action_tags[0]["text_box"][0]
			else:
				push_warning(str(current_action, " is missing one of the following components: [text_box][text_string] -- action failed"))
				emit_signal("failure")
				return
			
			dialogue_box.start_dialogue(name_string, dialogue_string, debug_mode)
			
		"fade screen":
			var transition_direction : bool = true
			var color : Color = Color.black
			var image : StreamTexture ## For later use in transition animation masks
			var duration : float = 0.0
			var ease_type : int = 0
			var blend : bool = true
			
			
			if action_tags[0].has("color_picker") && action_tags[0].has("image") && action_tags[0].has("transition_settings"):
				
				var color_array : Array = action_tags[0]["color_picker"][0].split_floats(",")
				color = Color(color_array[0], color_array[1], color_array[2], 1.0)
				
				transition_direction = action_tags[0]["transition_settings"][0]
				
				ease_type = action_tags[0]["transition_settings"][1]
				
				duration = float(action_tags[0]["transition_settings"][2])
				
				blend = bool(action_tags[0]["color_picker"][1])
				
#				image = action_tags[0]["image"]  ## For later use in transition animation masks
				
				if action_tags[0]["transition_settings"][0]:
					if !bool(action_tags[0]["color_picker"][1]):
						overlay_color.color = color
				else:
					if !overlay_color.visible:
						overlay_color.color = Color(color.r, color.g, color.b, 0.0)
					elif !bool(action_tags[0]["color_picker"][1]):
						overlay_color.color = Color(color.r, color.g, color.b, 0.0)
				
				overlay_color.fade_overlay(transition_direction, color, duration, ease_type, blend)
				
				# Overlay needs to call success or failure signal
			else:
				push_warning(str(current_action, " is missing one of the following components: [color_picker][transition_settings][image] -- action failed"))
				emit_signal("failure")
				return
			
		"modulate scene color":
			var color : Color = Color.black
			var image : StreamTexture ## For later use in transition animation masks
			var duration : float = 0.0
			var ease_type : int = 0
			
			
			if action_tags[0].has("color_picker") && action_tags[0].has("image") && action_tags[0].has("transition_settings"):
				
				var color_array : Array = action_tags[0]["color_picker"][0].split_floats(",")
				color = Color(color_array[0], color_array[1], color_array[2], 1.0)
				
				ease_type = action_tags[0]["transition_settings"][1]
				
				duration = float(action_tags[0]["transition_settings"][2])
				
#				image = action_tags[0]["image"]  ## For later use in transition animation masks
				
				screen_space_fx.modulate_screen(color, duration, ease_type)
				
				# Modulation needs to call success or failure signal
			else:
				push_warning(str(current_action, " is missing one of the following components: [color_picker][transition_settings][image] -- action failed"))
				emit_signal("failure")
				return
			
		
		"print":
				var message : String
				var success : bool = false
				
				if action_tags[0].has("debug_message"):
					message = action_tags[0]["debug_message"]
				else:
					push_warning(str(current_action, " is missing its debug message component -- action failed"))
					emit_signal("failure")
					return
				
				if action_tags[0].has("debug_options"):
					var debug_options : Array = action_tags[0]["debug_options"]
					
					match int(debug_options[0]):
						0:
							print(message)
							success = true
						1:
							push_warning(message)
							success = true
						2:
							push_error(message)
							success = true
						_:
							push_warning(str(current_action, " **unexpected index at debug_options component -- action failed"))
							emit_signal("failure")
							return
							
					if debug_options[1]:
						if !Engine.is_editor_hint() && !debug_mode:
							breakpoint
						else:
							printerr("Breakpoint")
					
					if success:
						emit_signal("success")
				
				else:
					push_warning(str(current_action, " is missing its debug options component -- action failed"))
					emit_signal("failure")
					return
		
		"wait":
			var wait_time : float = 0.01
			
			if action_tags[0].has("value"):
				wait_time = action_tags[0]["value"][0]
			else:
				push_warning(str(current_action, " is missing one of the following components: [value] -- action failed"))
				emit_signal("failure")
				return
			
			$InputControl.wait_for_time(wait_time)
		
		_:
			emit_signal("failure")











func get_initial_file() -> String:
	var file_path : String = ""
	
	var game_controller : Object
	if get_node_or_null("/root/yume_game_controller"):
		game_controller = get_node("/root/yume_game_controller")
	
	var story_data_path : String = str(game_controller.directory_paths["story_data"], "/story_data.yvndata")
	
	var story_data_file : File = File.new()
	var story_data : Array = []
	
	if story_data_file.file_exists(story_data_path):
#		print("story_data_file_exists")
		story_data_file.open(story_data_path, File.READ)
		
		while !story_data_file.eof_reached():
			var next : String = story_data_file.get_line()
			if next:
				story_data.append(parse_json(next))
		
		story_data_file.close()
	else:
		push_error(str("Could not locat story data file ", story_data_path))
	
#	print(story_data)
	
	if story_data.size() > 0:
		if typeof(story_data[0]) == TYPE_DICTIONARY:
			if story_data[0].has("chapters"):
				if story_data[0]["chapters"].keys().size() > 0:
					if story_data[0]["chapters"]["Chapter 1"]["scenes"].keys().size() > 0:
						file_path = story_data[0]["chapters"]["Chapter 1"]["scenes"]["Scene 1"]["script_path"].replace(".yscndata", ".yscn")
	
#	print(file_path)
	
	return file_path



func _get_object_child_nodes(object:Object) -> Array:
	# Recursively populate an array with all the child nodes of the specified object
	var child_object_array : Array = []
	child_object_array.append(object.get_children())
	
	if object.get_children().size() > 0:
		for i in object.get_children():
			child_object_array += _get_object_child_nodes(i)
	
	return child_object_array


func _filter_array(array:Array) -> Array:
	# Unconcatenate arrays and remove empty arrays
	var base_array : Array = array.duplicate(true)
	var new_array : Array = []
	
	for i in base_array.size():
		if base_array[i] is Array:
			if base_array[i].size() > 0:
				for x in base_array[i].size():
					new_array.append(base_array[i][x])
		else:
			new_array.append(base_array[i])
	
	return new_array

