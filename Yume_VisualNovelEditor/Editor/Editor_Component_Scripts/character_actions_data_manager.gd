tool
extends Node

var character_dictionary : Dictionary = {} setget character_data_updated

var character_related_nodes : Array = []
var character_event_tracker : Array = []
var stage_state_list : Array = []


signal update_character_data
signal update_stage_data





# warnings-disable
func _ready() -> void:
	get_parent().connect("node_added", self, "build_data_lists")
	get_parent().connect("node_removed", self, "build_data_lists")
	get_parent().connect("node_rearranged", self, "build_data_lists")

func _setup() -> void:
	build_data_lists()

func _reset() -> void:
	character_dictionary.clear()
	_reset_lists()


func _reset_lists() -> void:
	character_related_nodes.clear()
	character_event_tracker.clear()
	stage_state_list.clear()



func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.scancode == KEY_5:
			print("From CADM:")
			print(character_related_nodes)
			print("")
			print(stage_state_list)



func character_data_updated(new_data:Dictionary) -> void:
	character_dictionary = new_data
	
	# Update Component Info
	emit_signal("update_character_data", new_data)



func build_data_lists() -> void:
	# Clear previous list data
	yield(get_tree().create_timer(0.001), "timeout")
	
	_reset_lists()
	
	# Build lists of objects with character related components and actions:
	for i in $"../ActionsList".get_children():
		
		# Automatically add character catgory nodes to character related nodes array
		match i.action_category.to_lower():
			"character":
				if !character_related_nodes.has(i):
					character_related_nodes.append(i)
		
		
		# Populate ordered list of character actions that effect the order and number of characters on the stage
		match i.action_title.to_lower():
			"character entrance":
				character_event_tracker.append(i)
			"character exit":
				character_event_tracker.append(i)
	
	
	yield(get_tree().create_timer(0.001), "timeout")
	generate_state_list()



func generate_state_list() -> void:
	var characters_on_stage : int = 0
	var character_stage_changes : Array = []
	
	
	for i in character_event_tracker.size():
		if is_instance_valid(character_event_tracker[i]):
			var character_stage_order : Array = []
			
			if i > 0:
				for x in character_stage_changes[i-1][1].size():
					character_stage_order.append(character_stage_changes[i-1][1][x])
			
			# Get action base title
			var action_name : String = character_event_tracker[i].name.to_lower()
			var action_title : String = action_name.split("_")[0]
			
			# Get action components
			var components : Dictionary = {}
			var ui_container : Object = character_event_tracker[i].find_node("UI", true,false)
			
			for x in ui_container.get_children():
				if x.name.find("text_string") != -1:
					components["text_string"] = x
					
				elif x.name.find("character_order") != -1:
					components["character_order"] = x
		
			# Parse action and component data to create stage event timeline
			match action_title:
				"character entrance":
					if components.has_all(["text_string", "character_order"]):
						if components["text_string"].character_code != "":
							characters_on_stage += 1
							
							match components["character_order"].character_placement_mode:
								0:
									character_stage_order.append([components["character_order"].character_stage_rid, components["text_string"].text_string, components["text_string"].character_code])
								1:
									pass
								2:
									pass
				
				"character exit":
					if components.has("text_string"):
						if components["text_string"].character_code != "":
							for y in character_stage_order.size():
								if character_stage_order[y].has(components["text_string"].character_code):
									character_stage_order.erase(character_stage_order[y])
									
									characters_on_stage -= 1
									characters_on_stage = int(clamp(characters_on_stage, 0, 100000))
									break
							
			
			character_stage_changes.append([characters_on_stage, character_stage_order])
		
		
		
		stage_state_list = character_stage_changes
		
		emit_signal("update_stage_data", stage_state_list)

