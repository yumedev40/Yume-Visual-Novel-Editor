tool
extends Control

onready var overlay_color = $"VISUAL_COMPONENTS/OverlayScreen/OverlayColor"

onready var screen_space_fx = $"VISUAL_COMPONENTS/ScreenSpaceEffects"


var raw_edit_preview : bool = false
var debug_mode : bool = false

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
	
#	if debug_mode:
#		print("VN stage is in Debug mode")
#	else:
#		print("VN stage is in Game mode")


func _reset() -> void:
	var nodes : Array = _filter_array(_get_object_child_nodes(self))
	for i in nodes:
		if i.has_method("_reset"):
			i.call("_reset")



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
#
	if debug_mode && !raw_edit_preview:
		action_tags.pop_front()
		update_action_state()


func on_action_failure() -> void:
#	print("action failed")
#
	if debug_mode && !raw_edit_preview:
		action_tags.pop_front()
		update_action_state()






# Call Preview Scene From Editor
func preview_complete_scene(chapter_scene:Array, filepath:String) -> void:
	progress_position = [chapter_scene[0], chapter_scene[1]]
	
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
		"breakpoint":
			if !Engine.is_editor_hint() && !debug_mode:
				breakpoint
			else:
				printerr("Breakpoint")
			emit_signal("success")
			
		"debug":
			print("Basic debug test node")
			emit_signal("success")
			
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
		_:
			emit_signal("failure")





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