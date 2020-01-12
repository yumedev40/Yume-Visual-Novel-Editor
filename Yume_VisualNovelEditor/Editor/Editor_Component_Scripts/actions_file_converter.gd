tool
extends Node




#warnings-disable
func _ready() -> void:
	pass


static func export_to_files(project_dir:String, scene_info:Dictionary, data:Array) -> Array:
	return generate_script_files(project_dir, scene_info, data)

static func import_from_file() -> void:
	pass




static func generate_script_files(project_dir:String, scene_info:Dictionary, data:Array) -> Array:
	
	#VN Script File
	var script_file_name : String = str(project_dir,"/story_data/story_files/", scene_info["chapter_number"], "_", scene_info["scene_number"], "_", scene_info["scene_name"], ".yscn")
	
	var script_file : File = File.new()
	script_file.open(script_file_name, File.WRITE)
	
	# Parse action node stack
	for i in data:
		if i["action_tag_values"].keys().size() > 1:
			var value_dictionary : Dictionary = {
				"action": i["name"]
			}
			
			for x in i["action_tag_values"].keys():
				value_dictionary[x] = i["action_tag_values"][x]
			
			script_file.store_line(to_json(value_dictionary))
		else:
			var value_dictionary : Dictionary = {
				"action": i["name"],
				str(i["action_tag_values"].keys()[0]): i["action_tag_values"][i["action_tag_values"].keys()[0]]
			}
			
			script_file.store_line(to_json(value_dictionary))
	
	
	script_file.close()
	
	
	
	#VN Scene Action List
	var scene_action_file_name : String = str(project_dir,"/story_data/story_files/", scene_info["chapter_number"], "_", scene_info["scene_number"], "_", scene_info["scene_name"], ".yscndata")
	
	var actions_file : File = File.new()
	actions_file.open(scene_action_file_name, File.WRITE)
	
	# Parse action node stack
	for i in data:
		actions_file.store_line(to_json(i))
	
	actions_file.close()
	
	
	
	
	return [script_file_name, scene_action_file_name]






static func clear_data(project_dir:String, scene_info:Dictionary) -> void:
	#VN Script File
	var script_file_name : String = str(project_dir,"/story_data/story_files/", scene_info["chapter_number"], "_", scene_info["scene_number"], "_", scene_info["scene_name"], ".yscn")
	
	var script_file : File = File.new()
	script_file.open(script_file_name, File.WRITE)
	
	# write_empty
	
	script_file.close()
	
	
	#VN Scene Action List
	var scene_action_file_name : String = str(project_dir,"/story_data/story_files/", scene_info["chapter_number"], "_", scene_info["scene_number"], "_", scene_info["scene_name"], ".yscndata")
	
	var actions_file : File = File.new()
	actions_file.open(scene_action_file_name, File.WRITE)
	
	# write_empty
	
	actions_file.close()
