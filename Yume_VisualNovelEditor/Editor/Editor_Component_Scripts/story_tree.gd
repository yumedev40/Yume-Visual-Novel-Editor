tool
extends Tree

signal item_rearranged(item, to_item, shift)

var editor_root : Object

var chapter_button : Object
var scene_button : Object

# UI variables
export(Color) var chapter_heading_bg : Color = Color.black


# story tree
var story_root : TreeItem
var current_selected : TreeItem

var current_opened : TreeItem setget _update_scene_title_tag

var rearranged : bool = false



#warnings-disable
func _ready() -> void:
	connect("item_selected", self, "_item_selected")
	connect("button_pressed", self, "_button_pressed")
	connect("item_activated", self, "_on_scene_open")
	connect("item_edited", self, "_on_item_edited")
	
	# Connect chapter rearrange signal
	connect("item_rearranged", self, "_on_item_rearranged")



func _setup() -> void:
	_setup_story_tree()
	rearranged = false




# Scene function
func _on_scene_open() -> void:
	var open_item : TreeItem = get_selected()
	
	if open_item == current_opened:
		editor_root._close_scene()
		
		current_opened.set_icon(0, null)
		current_opened.clear_custom_bg_color(0)
		current_opened.clear_custom_bg_color(1)
		
		current_opened.clear_custom_color(0)
		current_opened.clear_custom_color(1)
		
		self.current_opened = null
		
		
		open_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/arrow_icon.png"))
	
		open_item.set_custom_bg_color(0, Color8(106, 158, 234))
		open_item.set_custom_bg_color(1, Color8(106, 158, 234))
		
		current_selected = open_item
		
		print("Visual novel scene [", open_item.get_parent().get_text(0), " - ", open_item.get_text(0), ": ", open_item.get_text(1) , " ] closed")
		
		return
	if open_item.get_metadata(0) == "scene_number":
		if current_opened:
			if open_item != current_opened:
				current_opened.set_icon(0, null)
				current_opened.clear_custom_bg_color(0)
				current_opened.clear_custom_bg_color(1)
				
				current_opened.clear_custom_color(0)
				current_opened.clear_custom_color(1)
		
		open_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/selected_open.png"))
		
		open_item.set_custom_bg_color(0, Color8(43, 196, 74))
		open_item.set_custom_bg_color(1, Color8(43, 196, 74))
		
		open_item.set_custom_color(0, Color.white)
		open_item.set_custom_color(1, Color.white)
		
		self.current_opened = open_item
		
		print("Visual novel scene [", open_item.get_parent().get_text(0), " - ", open_item.get_text(0), ": ", open_item.get_text(1) , " ] opened")




# Story tree 
func _setup_story_tree() -> void:
	story_root = create_item()
	story_root.set_text(0, "StoryTree")


func _refresh_tree() -> void:
	clear()
	_setup_story_tree()


func _item_selected() -> void:
	ensure_cursor_is_visible()
	
	var tree_item : TreeItem = get_selected()
	
	if current_selected:
		if tree_item != current_selected:
			match current_selected.get_metadata(0):
				"chapter_number":
					current_selected.set_icon(0, null)
					current_selected.set_custom_bg_color(0, chapter_heading_bg)
					current_selected.set_custom_bg_color(1, chapter_heading_bg)
					
					current_selected.clear_custom_color(0)
					current_selected.clear_custom_color(1)
				"scene_number":
					current_selected.set_icon(0, null)
					current_selected.clear_custom_bg_color(0)
					current_selected.clear_custom_bg_color(1)
					
					current_selected.clear_custom_color(0)
					current_selected.clear_custom_color(1)
	if current_opened:
		if tree_item != current_opened:
			current_opened.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/script_icon.png"))
			
			current_opened.set_custom_bg_color(0, Color8(45,145,65))
			current_opened.set_custom_bg_color(1, Color8(45,145,65))
			
			current_opened.set_custom_color(0, Color.white)
			current_opened.set_custom_color(1, Color.white)
	
	match tree_item.get_metadata(0):
		"chapter_number":
			tree_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/arrow_icon.png"))
			
			tree_item.set_custom_bg_color(0, Color8(106, 158, 234))
			tree_item.set_custom_bg_color(1, Color8(106, 158, 234))
			
			current_selected = tree_item
			
			scene_button.disabled = false
		"scene_number":
			if current_opened == tree_item:
				tree_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/selected_open.png"))
				
				tree_item.set_custom_bg_color(0, Color8(43, 196, 74))
				tree_item.set_custom_bg_color(1, Color8(43, 196, 74))
			else:
				tree_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/arrow_icon.png"))
			
				tree_item.set_custom_bg_color(0, Color8(106, 158, 234))
				tree_item.set_custom_bg_color(1, Color8(106, 158, 234))
			
			current_selected = tree_item
			
			scene_button.disabled = false


func _button_pressed(item:TreeItem, column:int, id:int) -> void:
	if item:
		match item.get_metadata(0):
			"chapter_number":
				scene_button.disabled = true
				
				if current_opened:
					var current_check : TreeItem = item.get_children()
					var flag : bool = false
					
					while is_instance_valid(current_check):
						if current_check == current_opened:
							flag = true
						
						current_check = current_check.get_next()
					
					if !flag:
#						current_opened = null
						_update_scene_title()
					else:
						current_opened = null
						_update_scene_title()
				
				item.get_parent().remove_child(item)
				_renumber_chapters()
				
				print("Visual novel chapter deleted")
			"scene_number":
				scene_button.disabled = true
				
				if item == current_opened:
					current_opened = null
					_update_scene_title()
				
				_renumber_scenes(item)
				item.get_parent().remove_child(item)
				
				if item != current_opened:
#					current_opened = current_opened
					_update_scene_title()
					
				print("Visual novel scene deleted")


func _renumber_chapters() -> void:
	var item : TreeItem = get_root().get_children()
	
	var chapter_count : int = 1
	
	while is_instance_valid(item):
		if item.get_metadata(0) == "chapter_number":
			item.set_text(0, str("Chapter ", chapter_count))
		
		chapter_count += 1
		item = item.get_next()


func _renumber_scenes(tree_item:TreeItem, do_not_rename:bool = true) -> void:
	var item : TreeItem = tree_item.get_parent().get_children()
	
	var scene_count : int = 1
	
	while is_instance_valid(item):
		if item != tree_item && do_not_rename:
			if item.get_metadata(0) == "scene_number":
				item.set_text(0, str("Scene ", scene_count))
			
			scene_count += 1
		elif !do_not_rename:
			item.set_text(0, str("Scene ", scene_count))
			
			scene_count += 1
		
		item = item.get_next()





# drag and drop
func _on_item_rearranged(item:Object, to_item:Object, shift:int):
	# If the to_item is valid
	if to_item:
		# And you're not dropping the item onto intself
		if item != to_item:
			# Check what kind of TreeItem is being dropped by metadata
			match item.get_metadata(0):
				"chapter_number":
					# Limit rearrange to other chapters
					if to_item.get_metadata(0) == "chapter_number":
						# Don't rearrange if trying to drop directly above currently selected item
						if to_item == item.get_prev() && shift == 1:
							return
						
						# activate rearrange flag
						rearranged = true
						
						# Create array for nodes below requested drop position
						var nodes_below : Array = []
						
						# Get tree item position to begin shifting nodes from
						var tree_item : TreeItem 
						match shift:
							1:
								tree_item = to_item.get_next()
							-1:
								tree_item = to_item
						
						# Shift dropped item to the bottom of tree
						item.move_to_bottom()
						
						# Populate array with tree items to shift down
						while is_instance_valid(tree_item):
							# Make sure dragged item is not added to shift array
							if tree_item != item:
								nodes_below.append(tree_item)
							
							tree_item = tree_item.get_next()
						
						# Iteration condition variable
						var i : int = 0
						
						# While i is in range of nodes_below array, move stored items to bottom of tree
						while i < nodes_below.size():
							nodes_below[i].move_to_bottom()
							i += 1
						
						# Renumber chapters
						_renumber_chapters()
						
						current_opened = current_opened
						_update_scene_title()
						
				"scene_number":
					# Handle Reparenting
					if to_item.get_metadata(0) == "chapter_number":
						
						# activate rearrange flag
						rearranged = true
						
						var item_parent : TreeItem = to_item
						
						var scene_item : TreeItem = create_item(item_parent)
						
						var scene_count : int = 0
						var items : TreeItem = item_parent.get_children()
						
						while is_instance_valid(items):
							scene_count += 1
							items = items.get_next()
						
						# Setup new scene in new parent chapter
						scene_item.set_text(0, str("Scene " , scene_count))
						
						scene_item.set_metadata(0, "scene_number")
						scene_item.set_metadata(1, "scene_title")
						
						scene_item.set_editable(1, true)
						
						scene_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
						
						# Copy title over to new object
						scene_item.set_text(1, item.get_text(1))
						
						# If dragged item was open, copy properties
						if item == current_opened:
							scene_item.set_custom_bg_color(0, Color8(43, 196, 74))
							scene_item.set_custom_bg_color(1, Color8(43, 196, 74))
						
							scene_item.set_custom_color(0, Color.white)
							scene_item.set_custom_color(1, Color.white)
						
							scene_item.set_tooltip(1, item.get_tooltip(1))
						
							scene_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/script_icon.png"))
						
							current_opened = scene_item
						
						
						# Renumber remaining scenes
						_renumber_scenes(item)
						
						scene_item.select(0)
						
						# Remove child from chapter
						item.get_parent().remove_child(item)
						
						current_opened = current_opened
						_update_scene_title()
						
					elif to_item.get_metadata(0) == "scene_number" && to_item.get_parent() != item.get_parent():
						# Don't rearrange if trying to drop directly on an item
						if shift == 0:
							return
						
						# activate rearrange flag
						rearranged = true
						
						var item_parent : TreeItem = to_item.get_parent()
						
						var scene_item : TreeItem = create_item(item_parent)
						
						var scene_count : int = 0
						var items : TreeItem = item_parent.get_children()
						
						while is_instance_valid(items):
							scene_count += 1
							items = items.get_next()
						
						# Setup new scene in new parent chapter
						scene_item.set_text(0, str("Scene " , scene_count))
						
						scene_item.set_metadata(0, "scene_number")
						scene_item.set_metadata(1, "scene_title")
						
						scene_item.set_editable(1, true)
						
						scene_item.add_button(1, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/close_icon.png"))
						
						# Copy title over to new object
						scene_item.set_text(1, item.get_text(1))
						
						# If dragged item was open, copy properties
						if item == current_opened:
							scene_item.set_custom_bg_color(0, Color8(43, 196, 74))
							scene_item.set_custom_bg_color(1, Color8(43, 196, 74))
						
							scene_item.set_custom_color(0, Color.white)
							scene_item.set_custom_color(1, Color.white)
						
							scene_item.set_tooltip(1, item.get_tooltip(1))
						
							scene_item.set_icon(0, preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/script_icon.png"))
						
							current_opened = scene_item
						
						
						# Create array for nodes below requested drop position
						var nodes_below : Array = []
						
						# Get tree item position to begin shifting nodes from
						var tree_item : TreeItem 
						match shift:
							1:
								tree_item = to_item.get_next()
							-1:
								tree_item = to_item
						
						
						# Populate array with tree items to shift down
						while is_instance_valid(tree_item):
							# Make sure dragged item is not added to shift array
							if tree_item != scene_item:
								nodes_below.append(tree_item)
							
							tree_item = tree_item.get_next()
						
						# Iteration condition variable
						var i : int = 0
						
						# While i is in range of nodes_below array, move stored items to bottom of tree
						while i < nodes_below.size():
							nodes_below[i].move_to_bottom()
							i += 1
						
						# renumber both chapters' scenes
						_renumber_scenes(item, true)
						_renumber_scenes(scene_item, false)
						
						scene_item.select(0)
						
						# Remove child from chapter
						item.get_parent().remove_child(item)
						
						current_opened = current_opened
						_update_scene_title()
						
					# Handle Rearranging
					elif to_item.get_metadata(0) == "scene_number":
						# Don't rearrange if trying to drop directly next to currently selected item or on an item
						if to_item == item.get_prev() && shift == 1:
							return
						if to_item == item.get_next() && shift == -1:
							return
						if shift == 0:
							return
						
						# activate rearrange flag
						rearranged = true
						
						# Create array for nodes below requested drop position
						var nodes_below : Array = []
						
						# Get tree item position to begin shifting nodes from
						var tree_item : TreeItem 
						match shift:
							1:
								tree_item = to_item.get_next()
							-1:
								tree_item = to_item
						
						# Shift dropped item to the bottom of tree
						item.move_to_bottom()
						
						# Populate array with tree items to shift down
						while is_instance_valid(tree_item):
							# Make sure dragged item is not added to shift array
							if tree_item != item:
								nodes_below.append(tree_item)
							
							tree_item = tree_item.get_next()
						
						# Iteration condition variable
						var i : int = 0
						
						# While i is in range of nodes_below array, move stored items to bottom of tree
						while i < nodes_below.size():
							nodes_below[i].move_to_bottom()
							i += 1
						
						# Renumber scenes
						_renumber_scenes(item, false)
						
						item.select(0)
						
						current_opened = current_opened
						_update_scene_title()


func _on_item_edited() -> void:
	_update_scene_title()


func _update_scene_title() -> void:
	if current_opened:
		editor_root.scene_title.get_node("Label").text = str("(", current_opened.get_parent().get_text(0), ": ",  current_opened.get_parent().get_text(1), ")  ", current_opened.get_text(0), " - ", current_opened.get_text(1),"")
		
		editor_root.scene_title.show()
		
		var regex : RegEx = RegEx.new()
		regex.compile("\\d+")
		var chapter_number : int = int(regex.search(current_opened.get_parent().get_text(0)).get_string())
		var scene_number : int = int(regex.search(current_opened.get_text(0)).get_string())
		
		var script_check : File = File.new()
		var script_filepath : String = ""
		
		if script_check.file_exists(current_opened.get_tooltip(1)):
			script_filepath = current_opened.get_tooltip(1)
		
		var info : Dictionary = {
			"chapter_number" : chapter_number,
			"chapter_title" : current_opened.get_parent().get_text(1),
			"scene_number" : scene_number,
			"scene_name" : current_opened.get_text(1),
			"tree_item" : current_opened,
			"scene_script_filepath" : script_filepath
		}
		
		editor_root.scene_actions_editor_panel.update_open_scene_info(info)
	else:
		editor_root.scene_title.get_node("Label").text = ""
		editor_root.scene_title.hide()
		editor_root.clear_info()




func get_drag_data(position:Vector2) -> Object:
	# Get currently selected tree item as drag data
	var item : TreeItem = get_selected()
	
	# Check item metadata to set drop mode flags
	match item.get_metadata(0):
		# Chapters should only be able to be rearranged, so they are dropped inbetween one another
		"chapter_number":
			set_drop_mode_flags(2)
		# Scenes should be able to be rearranged and nested, so they can be dropped inbetween and on other items
		"scene_number":
			set_drop_mode_flags(1 | 2)
	
	# Generate a preview label with the item text so you know what you're dragging
	var preview : Label = Label.new()
	preview.text = item.get_text(0)
	set_drag_preview(preview)
	
	# Return the item object
	return item


func can_drop_data(position:Vector2, data: Object) -> bool:
	# Check that drop area is valid
	return data is TreeItem


func drop_data(position:Vector2, data:Object) -> void:
	# Get tree item where drop is requested
	var to_item : TreeItem = get_item_at_position(position)
	# Get the requested drop position relative to the tree item you're dropping onto
	var shift = get_drop_section_at_position(position)
	
	# Emit the rearrange signal
	emit_signal("item_rearranged", data, to_item, shift)



func _update_scene_title_tag(item:TreeItem) -> void:
#	if current_opened && !item :
#		print("Visual novel scene [", current_opened.get_parent().get_text(0), " - ", current_opened.get_text(0), ": ", current_opened.get_text(1) , " ] closed")
	
	if current_opened:
		if item:
			if current_opened != item:
				editor_root._close_scene()
	
	current_opened = item
	
	if item:
		editor_root.scene_title.get_node("Label").text = str("(", item.get_parent().get_text(0), ": ",  item.get_parent().get_text(1), ")  ", item.get_text(0), " - ", item.get_text(1),"")
		
		editor_root.scene_title.show()
		
		var regex : RegEx = RegEx.new()
		regex.compile("\\d+")
		var chapter_number : int = int(regex.search(item.get_parent().get_text(0)).get_string())
		var scene_number : int = int(regex.search(item.get_text(0)).get_string())
		
		var script_check : File = File.new()
		var script_filepath : String = ""
		
		if script_check.file_exists(item.get_tooltip(1)):
			script_filepath = item.get_tooltip(1)
		
		var info : Dictionary = {
			"chapter_number" : chapter_number,
			"chapter_title" : item.get_parent().get_text(1),
			"scene_number" : scene_number,
			"scene_name" : item.get_text(1),
			"tree_item" : item,
			"scene_script_filepath" : script_filepath
		}
		
		editor_root._open_scene(info, rearranged)
	else:
		editor_root.scene_title.get_node("Label").text = ""
		editor_root.scene_title.hide()
		
#		editor_root._close_scene()
	
	#reset_rearranged_flag
	rearranged = false
