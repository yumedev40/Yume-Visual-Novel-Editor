tool
extends Tabs

var node_type_icon := preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Scenes/NodeTypeIcon.tscn")

export(Color) var proportional_editing_linked_color : Color = Color.white


# Stage Visual Components
export(NodePath) var editor_root_path : NodePath
var editor_root : Object

export(NodePath) var catalog_root_path : NodePath
var catalog_root : Object

export(NodePath) var stage_character_instance_field_path : NodePath
var stage_character_instance_field : Object

export(NodePath) var stage_instance_pos_3D_path : NodePath
var stage_instance_pos_3D : Object

export(NodePath) var stage_instance_pos_2D_path : NodePath
var stage_instance_pos_2D : Object

export(NodePath) var camera_path : NodePath
var camera : Object

export(NodePath) var camera2D_path : NodePath
var camera2D : Object

export(NodePath) var camera_slider_path : NodePath
var camera_slider : Object

export(NodePath) var ui_bar_bg_path : NodePath
var ui_bar_bg : Object

export(NodePath) var ui_bar_path : NodePath
var ui_bar : Object

export(NodePath) var ui_bar_middle_path : NodePath
var ui_bar_middle : Object

export(NodePath) var viewport_container_path : NodePath
var viewport_container : Object

export(NodePath) var viewport_texture_path : NodePath
var viewport_texture : Object

export(NodePath) var viewport3D_path : NodePath
var viewport3D : Object

export(NodePath) var viewport2D_path : NodePath
var viewport2D : Object

export(NodePath) var preview_container_path : NodePath
var preview_container : Object

export(NodePath) var display_components_path : NodePath
var display_components : Object

export(NodePath) var animation_components_path : NodePath
var animation_components : Object

export(NodePath) var visual_preview_tabs_path : NodePath
var visual_preview_tabs : Object



# Box Sprite Components
export(NodePath) var box_sprite_dimension_x_path : NodePath
var box_sprite_dimension_x : Object

export(NodePath) var box_sprite_dimension_y_path : NodePath
var box_sprite_dimension_y : Object

export(NodePath) var proportional_editing_path : NodePath
var proportional_editing : Object

export(NodePath) var transparency_toggle_path : NodePath
var transparency_toggle : Object

export(NodePath) var box_sprite_viewport_path : NodePath
var box_sprite_viewport : Object

export(NodePath) var box_sprite_preview_path : NodePath
var box_sprite_preview : Object

export(NodePath) var box_sprite_2d_container_path : NodePath
var box_sprite_2d_container : Object

export(NodePath) var box_sprite_3d_container_path : NodePath
var box_sprite_3d_container : Object

export(NodePath) var box_main_instance_field_path : NodePath
var box_main_instance_field : Object

export(NodePath) var box_sprite_display_components_path : NodePath
var box_sprite_display_components : Object

export(NodePath) var box_sprite_animation_components_path : NodePath
var box_sprite_animation_components : Object

export(NodePath) var box_sprite_mask_field_path : NodePath
var box_sprite_mask_field : Object

export(NodePath) var box_sprite_mask_presets_path : NodePath
var box_sprite_mask_presets : Object

export(NodePath) var expressions_menu_path : NodePath
var expressions_menu : Object




#internal
var character_instance_path : String

var box_sprite_dimensions : Vector2 = Vector2(256, 256)






#warnings-disable
func _ready() -> void:
	setup_ui() 
	
	if stage_character_instance_field:
		(stage_character_instance_field as LineEdit).connect("text_changed", self, "on_instance_field_text_changed")
		
		(stage_character_instance_field as LineEdit).connect("text_entered", self, "on_instance_field_text_entered")
		
		(stage_character_instance_field as LineEdit).connect("focus_exited", self, "on_instance_field_focus_exited")
	
	if camera_slider:
		(camera_slider as HSlider).connect("value_changed", self, "_on_HSlider_value_changed")
	
	if box_sprite_dimension_x:
		(box_sprite_dimension_x as SpinBox).connect("value_changed", self, "on_box_sprite_dimension_x_value_changed")
		
		(box_sprite_dimension_x as SpinBox).connect("changed", self, "on_box_sprite_dimension_x_changed")
	
	if box_sprite_dimension_y:
		(box_sprite_dimension_y as SpinBox).connect("value_changed", self, "on_box_sprite_dimension_y_value_changed")
		
		(box_sprite_dimension_y as SpinBox).connect("changed", self, "on_box_sprite_dimension_y_changed")
	
	if transparency_toggle:
		(transparency_toggle as CheckButton).connect("toggled", self, "on_box_sprite_transparency_toggled")
	
	if proportional_editing:
		(proportional_editing as TextureButton).connect("toggled", self, "on_proportional_editing_toggled")
	
	if box_main_instance_field:
		(box_main_instance_field as LineEdit).connect("text_changed", self, "on_main_instance_text_changed")
		
		(box_main_instance_field as LineEdit).connect("text_entered", self, "on_main_instance_text_entered")
	
	if box_sprite_mask_field:
		(box_sprite_mask_field as LineEdit).connect("text_changed", self, "on_sprite_mask_text_changed")
		(box_sprite_mask_field as LineEdit).connect("text_entered", self, "on_sprite_mask_text_entered")
	
	if box_sprite_mask_presets:
		for i in (box_sprite_mask_presets as GridContainer).get_children():
			(i as TextureButton).connect("pressed", self, "on_preset_button_pressed", [i])
	
#	preview_ui_tween = $"PanelContainer/VBoxContainer/HBoxContainer2/TabContainer/Stage Visual/PanelContainer/VBoxContainer/Panel/PreviewUI"



func _setup(data:Dictionary) -> void:
	# Setup Expressions
	expressions_menu._setup(data)
	
	
	#Reset UI
	if viewport3D:
		viewport3D.size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
	
	if viewport2D && viewport_texture:
		viewport2D.size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
		
		viewport_texture.texture = viewport2D.get_texture()
	
	if stage_instance_pos_2D:
		(stage_instance_pos_2D as Node2D).position = Vector2(ProjectSettings.get("display/window/size/width") * 0.5, ProjectSettings.get("display/window/size/height") * 0.5)
		
		stage_instance_pos_2D.scale = stage_instance_pos_2D.starting_scale
	
	_clear_character()
	
	(visual_preview_tabs as TabContainer).current_tab = 0
	
	if camera:
		(camera as Spatial).global_transform.origin.z = camera.starting_pos
	
	if camera2D :
		(camera2D as Camera2D).zoom = Vector2(1,1)
	
	if camera_slider:
		(camera_slider as HSlider).value = 0
	
	clear_box_sprite()
	
	for i in box_sprite_mask_presets.get_children():
		i.modulate = Color.white
	
	
	
	
	if data.has("visuals"):
		if data["visuals"].has("stage_instance_path") && data["visuals"].has("box_sprite_dimensions") && data["visuals"].has("box_sprite_transparent") && data["visuals"].has("box_sprite_dimensions_proportional") && data["visuals"].has("box_sprite_instance_path") &&  data["visuals"].has("box_sprite_mask_image") && data["visuals"].has("box_sprite_mask_preset"):
			
			
			if data["visuals"]["stage_instance_path"] == "" && data["visuals"]["box_sprite_instance_path"] != "":
				(visual_preview_tabs as TabContainer).current_tab = 1
			
			
			# Stage Instance
			if stage_character_instance_field:
				(stage_character_instance_field as LineEdit).text = data["visuals"]["stage_instance_path"]
				
				if data["visuals"]["stage_instance_path"] != "":
					var file_check : File = File.new()
					
					if file_check.file_exists(data["visuals"]["stage_instance_path"]):
						character_instance_path = data["visuals"]["stage_instance_path"]
						stage_character_instance_field.set("custom_colors/font_color", Color.green)
						
						_add_character_instance(data["visuals"]["stage_instance_path"])
						
						expressions_menu.add_expressions_button.disabled = false
					else:
						stage_character_instance_field.set("custom_colors/font_color", Color.red)
						character_instance_path = ""
				
						if catalog_root.current_selected:
							catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_path"] = ""
				
				else:
					stage_character_instance_field.set("custom_colors/font_color", null)
			
			
			# Box Sprite
			if box_sprite_dimension_x:
				(box_sprite_dimension_x as SpinBox).value = data["visuals"]["box_sprite_dimensions"]["x"]
			
			if box_sprite_dimension_y:
				(box_sprite_dimension_y as SpinBox).value = data["visuals"]["box_sprite_dimensions"]["y"]
			
			if transparency_toggle:
				(transparency_toggle as CheckButton).pressed = data["visuals"]["box_sprite_transparent"]
			
			if proportional_editing:
				(proportional_editing as TextureButton).pressed = data["visuals"]["box_sprite_dimensions_proportional"]
				
				update_dimensions_ui()
			
			if box_main_instance_field:
				var box_instance_path : String = data["visuals"]["box_sprite_instance_path"]
				
				(box_main_instance_field as LineEdit).text = box_instance_path
				
				add_main_box_sprite(box_instance_path)
				
				if box_instance_path != "":
					expressions_menu.add_expressions_button.disabled = false
			
			if box_sprite_mask_field:
				if data["visuals"]["box_sprite_mask_image"] != "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png":
					(box_sprite_mask_field as LineEdit).text = data["visuals"]["box_sprite_mask_image"]
				else:
					(box_sprite_mask_field as LineEdit).text = ""
				
				box_sprite_preview.material.set("shader_param/mask_image", load(data["visuals"]["box_sprite_mask_image"]))
				
				if box_sprite_mask_presets:
					var preset_index : int = int(data["visuals"]["box_sprite_mask_preset"])
					
					if preset_index > 0:
						box_sprite_mask_presets.get_child(preset_index).modulate = Color.green
						
						(box_sprite_mask_field as LineEdit).set("custom_colors/font_color", null)
						
					elif preset_index == 0:
						(box_sprite_mask_field as LineEdit).set("custom_colors/font_color", null)
						
					else:
						(box_sprite_mask_field as LineEdit).set("custom_colors/font_color", Color.green)
			
			setup_box_sprite_preview()
			
		else:
			push_error("Character visuals is missing necessary data, check file for stage visuals variables and box sprite variables")
	else:
		push_error("Character visuals information is missing, check if file contains data")
		_reset()



func _reset() -> void:
	# Reset Expressions
	expressions_menu._reset()
	
	if stage_character_instance_field:
		(stage_character_instance_field as LineEdit).text = ""
		(stage_character_instance_field as LineEdit).set("custom_colors/font_color", null)
	
	character_instance_path = ""
	
	_clear_character()
	
	if camera:
		(camera as Spatial).global_transform.origin.z = camera.starting_pos
	
	if camera2D :
		(camera2D as Camera2D).zoom = Vector2(1,1)
	
	if stage_instance_pos_2D:
		(stage_instance_pos_2D as Node2D).scale = stage_instance_pos_2D.starting_scale
	
	if camera_slider:
		(camera_slider as HSlider).value = 0
	
	reset_instance_component_info()
	
	(visual_preview_tabs as TabContainer).current_tab = 0
	
	if box_sprite_dimension_x:
		(box_sprite_dimension_x as SpinBox).value = 256
		box_sprite_dimension_x.get_line_edit().set("custom_colors/font_color", null)
	
	if box_sprite_dimension_y:
		(box_sprite_dimension_y as SpinBox).value = 256
		box_sprite_dimension_y.get_line_edit().set("custom_colors/font_color", null)
	
	if transparency_toggle:
		(transparency_toggle as CheckButton).pressed = false
	
	reset_box_sprite_preview()
	
	clear_box_sprite()
	
	(box_main_instance_field as LineEdit).set("custom_colors/font_color", null)
	
	(box_main_instance_field as LineEdit).text = ""
	
	if box_sprite_mask_field:
		(box_sprite_mask_field as LineEdit).text = ""
		
		box_sprite_mask_field.set("custom_colors/font_color", null)
		
		box_sprite_preview.material.set("shader_param/mask_image", load("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"))
		
	for i in box_sprite_mask_presets.get_children():
		if i.name.to_lower() != "nomask":
			i.modulate = Color.white
	
	reset_box_sprite_component_info()
	
	expressions_menu.add_expressions_button.disabled = true















# Stage Visual Menu
func on_instance_field_text_changed(new_text:String) -> void:
	on_instance_field_text_entered(new_text)



func on_instance_field_text_entered(new_text:String) -> void:
	var file_check : File = File.new()
	var flag : bool = false
	
	if file_check.file_exists(new_text):
		flag = true
	else:
		stage_character_instance_field.set("custom_colors/font_color", Color.red)
		character_instance_path = ""
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_path"] = ""
			
			_clear_character()
			
			if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_instance_path"] == "":
				expressions_menu.add_expressions_button.disabled = true
		
		reset_instance_component_info()
		
		return
	
	if flag:
		match new_text.get_extension():
			"tscn":
				flag = true
				stage_character_instance_field.set("custom_colors/font_color", Color.green)
				character_instance_path = new_text
				
				if catalog_root.current_selected:
					catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_path"] = new_text
				
				_add_character_instance(new_text)
				
				if catalog_root.current_selected:
					expressions_menu.setup_animation_selection_ui(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"], 1)
				
				expressions_menu.add_expressions_button.disabled = false
			_:
				flag = false
				stage_character_instance_field.set("custom_colors/font_color", Color.red)
				character_instance_path = ""
				
				if catalog_root.current_selected:
					catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_path"] = ""
					
					_clear_character()
					
					if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_instance_path"] == "":
						expressions_menu.add_expressions_button.disabled = true
				
				reset_instance_component_info()



func on_instance_field_focus_exited() -> void:
	if stage_character_instance_field:
		on_instance_field_text_entered( (stage_character_instance_field as LineEdit).text )



func _add_character_instance(path:String) -> void:
	if stage_instance_pos_3D && stage_instance_pos_2D:
		for i in stage_instance_pos_3D.get_children():
			i.queue_free()
		
		for i in stage_instance_pos_2D.get_children():
			i.queue_free()
		
		var instance : Object = load(path).instance()
		
		if instance is Spatial:
			
			stage_instance_pos_3D.add_child(instance)
			show_preview_ui()
			update_instance_component_info(instance)
			
		elif instance is Node2D:
			
			stage_instance_pos_2D.add_child(instance)
			show_preview_ui()
			update_instance_component_info(instance)
			
		elif instance is CanvasItem:
			
			stage_instance_pos_2D.add_child(instance)
			
			var rect_size_ : Vector2 = (instance as Control).rect_size
			(instance as Control).rect_position = Vector2(-rect_size_.x * 0.5, -rect_size_.y * 0.5)
			
			show_preview_ui()
			update_instance_component_info(instance)
			
		else:
			push_error("Root Node for specified character scene must inherit from either SPATIAL, NODE2D, or CANVASITEM")
			_clear_character()
			hide_preview_ui()



func _clear_character() -> void:
	if stage_instance_pos_3D:
		for i in stage_instance_pos_3D.get_children():
			i.queue_free()
	
	if stage_instance_pos_2D:
		for i in stage_instance_pos_2D.get_children():
			i.queue_free()
	
	hide_preview_ui()



func _on_HSlider_value_changed(value: float) -> void:
	if camera:
		(camera as Spatial).pos_target = value * 5
		
		if !(camera as Spatial).is_processing():
			(camera as Spatial).set_process(true)
	
#	if camera2D :
#		(camera2D as Camera2D).zoom = Vector2(1 + value,1 + value)
#
#		print((camera2D as Camera2D).zoom)
	
	if stage_instance_pos_2D:
		var value_adjust : float = 0.0
		if value > 0:
			value_adjust = range_lerp(value, 0.01, 1, 0.01, 1.5)
		elif value < 0:
			value_adjust = range_lerp(value, -0.01, -1, -0.01, -0.6)
		
		(stage_instance_pos_2D as Node2D).target_scale = Vector2(clamp(1 + value_adjust, 0.1, 1000), clamp(1 + value_adjust, 0.1, 1000))
		
		if !(stage_instance_pos_2D as Node2D).is_processing():
			(stage_instance_pos_2D as Node2D).set_process(true)



func hide_preview_ui() -> void:
	if ui_bar && ui_bar_bg:
		
		if camera:
			(camera as Spatial).global_transform.origin.z = camera.starting_pos
		
		if camera2D :
			(camera2D as Camera2D).zoom = Vector2(1,1)
		
		if stage_instance_pos_2D:
			(stage_instance_pos_2D as Node2D).scale = stage_instance_pos_2D.starting_scale
		
		if camera_slider:
			(camera_slider as HSlider).value = 0
		
		ui_bar_bg.hide()
		
		ui_bar_middle.hide()
		
		ui_bar.hide()


func show_preview_ui() -> void:
	if ui_bar && ui_bar_bg:
		
		ui_bar_bg.show()
		
		ui_bar_middle.show()
		
		ui_bar.show()



func update_instance_component_info(instance:Object) -> void:
	# Clear previous nodepath info
	clear_visual_instance_anim_path_array("stage_instance_animation_player_paths")
	clear_visual_instance_anim_path_array("stage_instance_sprite_frames_paths")
	
	
	# Update Node UI
	if display_components && animation_components:
		for i in display_components.get_children():
			i.queue_free()
		
		for i in animation_components.get_children():
			i.queue_free()
	
	# Add parent instance to node list
	var node : Object = instance.duplicate(true)
	var nodes_list : Array = _filter_array(_get_object_child_nodes(node))
	
	nodes_list.push_front(node)
	
	var node_type_array : Array = []
	
	# Populate component icons
	for i in nodes_list:
		if i is Sprite:
			add_node(1, display_components)
			node_type_array.append("Sprite")
			
		elif i is AnimatedSprite:
			add_node(2, display_components)
			node_type_array.append("AnimatedSprite")
			
			add_node(9, animation_components)
			
			set_visual_instance_anim_path(i, node, "stage_instance_sprite_frames_paths")
			
		elif i is Sprite3D:
			add_node(4, display_components)
			node_type_array.append("Sprite3D")
		
		elif i is AnimatedSprite3D:
			add_node(5, display_components)
			node_type_array.append("AnimatedSprite3D")
		
			add_node(9, animation_components)
			
			set_visual_instance_anim_path(i, node, "stage_instance_sprite_frames_paths")
		
		elif i is Skeleton2D:
			add_node(3, display_components)
			node_type_array.append("Skeleton2D")
			
		elif i is Skeleton:
			add_node(6, display_components)
			node_type_array.append("Skeleton")
			
		elif i is CanvasItem:
			add_node(0, display_components)
			node_type_array.append("CanvasItem")
		
		elif i is AnimationTreePlayer:
			add_node(8, animation_components)
			node_type_array.append("AnimationTreePlayer")
		
		elif i is AnimationPlayer:
			add_node(7, animation_components)
			node_type_array.append("AnimationPlayer")
			
			set_visual_instance_anim_path(i, node, "stage_instance_animation_player_paths")
	
	# Setup error icons if no usuable components found
	if animation_components.get_child_count() <= 0:
		add_node(10, animation_components)
	
	if display_components.get_child_count() <= 0:
		add_node(10, display_components)
	
	# Check for multiple of the same node
	if node_type_array.size() > 0:
		for i in node_type_array:
			if node_type_array.count(i) > 1:
				
				match i:
					"CanvasItem":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 0:
								x.material.set("shader_param/multiple", true)
					"Sprite":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 1:
								x.material.set("shader_param/multiple", true)
					"AnimatedSprite":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 2:
								x.material.set("shader_param/multiple", true)
					"Sprite3D":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 4:
								x.material.set("shader_param/multiple", true)
						
					"AnimatedSprite3D":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 5:
								x.material.set("shader_param/multiple", true)
						
					"Skeleton2D":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 3:
								x.material.set("shader_param/multiple", true)
						
					"Skeleton":
						for x in display_components.get_children():
							if x.material.get("shader_param/index") == 6:
								x.material.set("shader_param/multiple", true)
	
	node.queue_free()



func reset_instance_component_info() -> void:
	# Reset Node UI
	if display_components && animation_components:
		for i in display_components.get_children():
			i.queue_free()
		
		for i in animation_components.get_children():
			i.queue_free()
	
	
	var node_icon := node_type_icon.instance()
	
	display_components.add_child(node_icon)
	
	node_icon.node_type = 10
	
	
	var node_icon2 := node_type_icon.instance()
	
	animation_components.add_child(node_icon2)
	
	node_icon2.node_type = 10
	
	
	
	if catalog_root.current_selected:
		if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"].has_all(["stage_instance_animation_player_paths", "stage_instance_sprite_frames_paths"]):
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_animation_player_paths"].clear()
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_sprite_frames_paths"].clear()
		
		
		for i in catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"].keys():
			for x in catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i]:
				for y in catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i].keys():
					if y.find("stage") != -1:
						if typeof(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]) == TYPE_DICTIONARY:
							if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y].has_all(["animation_player","animation_name","animation_menu_index","animation_menu_text"]):
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_player"] = ""
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_name"] = ""
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_menu_index"] = 0
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_menu_text"] = ""
		
		
		expressions_menu.setup_animation_selection_ui(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"], 1)



func add_node(index:int, container:Object) -> void:
	if !component_check(index, container):
		add_node_icon(index, container)



func component_check(index:int, component_container:Object) -> bool:
	var flag : bool = false
	
	if component_container:
		for i in component_container.get_children():
			if "node_type" in i:
				if i.node_type == index:
					flag = true
			else:
				i.queue_free()
	return flag



func add_node_icon(index:int, component_container:Object) -> void:
	var node_icon := node_type_icon.instance()
	
	node_icon.node_type = index
	
	component_container.add_child(node_icon.duplicate(true))
	
	node_icon.queue_free()













# Box Sprite Menu

func add_main_box_sprite(path:String) -> bool:
	var flag : bool = false
	
	clear_box_sprite()
	
	match path.get_extension():
		"tscn":
			flag = true
	
	if flag:
		var file_check : File = File.new()
		
		if file_check.file_exists(path):
			var scene_instance = load(path).instance().duplicate(true)
			
			if scene_instance is Node2D:
				box_sprite_2d_container.add_child(scene_instance)
				
				# Position Instance
				scene_instance.position = box_sprite_viewport.size * 0.5
				
				# Scale Instance
				if scene_instance.has_method("get_rect"):
					var new_scale : Vector2 = get_2D_scale_factor(scene_instance.get_rect().size)
					var scale_factor_x : float = new_scale.x / scene_instance.get_rect().size.x
					var scale_factor_y : float = new_scale.y / scene_instance.get_rect().size.y
					
					scene_instance.apply_scale(Vector2(scale_factor_x, scale_factor_y))
				
				update_box_sprite_component_info(scene_instance)
				
			elif scene_instance is CanvasItem:
				box_sprite_2d_container.add_child(scene_instance)
				
				# Scale Instance
				if "rect_size" in scene_instance:
					scene_instance.rect_scale = Vector2.ONE
					
					var new_scale : Vector2 = get_2D_scale_factor(scene_instance.rect_size)
					var scale_factor_x : float = new_scale.x / scene_instance.rect_size.x
					var scale_factor_y : float = new_scale.y / scene_instance.rect_size.y
					
					scene_instance.rect_scale = scene_instance.rect_scale * Vector2(scale_factor_x, scale_factor_y)
					
				# Position Instance
				scene_instance.rect_position = (box_sprite_viewport.size * 0.5) - ((scene_instance.rect_size * scene_instance.rect_scale) * 0.5)
				
				update_box_sprite_component_info(scene_instance)
				
			elif scene_instance is Spatial:
				box_sprite_3d_container.add_child(scene_instance)
				
				update_box_sprite_component_info(scene_instance)
				
			else:
				scene_instance.queue_free()
				
				clear_box_sprite()
				
				push_error("Invalid Scene -- the dialogue box sprite instance must have a Node2D, CanvasItem, or Spatial root node.")
				
				flag = false
				
		else:
			clear_box_sprite()
			
			flag = false
	
	box_sprite_instance_field_color(flag)
	
	if !flag:
		reset_box_sprite_component_info()
	
	return flag


func clear_box_sprite() -> void:
	if box_sprite_2d_container:
		if box_sprite_2d_container.get_child_count() > 0:
			for i in box_sprite_2d_container.get_children():
				i.queue_free()
	
	if box_sprite_3d_container:
		if box_sprite_3d_container.get_child_count() > 0:
			for i in box_sprite_3d_container.get_children():
				i.queue_free()


func on_main_instance_text_changed(new_text:String) -> void:
	var text_String : String = ""
	
	if add_main_box_sprite(new_text):
		text_String = new_text
		expressions_menu.add_expressions_button.disabled = false
		
		if catalog_root.current_selected:
			expressions_menu.setup_animation_selection_ui(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"], 2)
	else:
		if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_path"] == "":
			expressions_menu.add_expressions_button.disabled = true
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_instance_path"] = text_String


func on_main_instance_text_entered(new_text:String) -> void:
	var text_String : String = ""
	
	if add_main_box_sprite(new_text):
		text_String = new_text
		expressions_menu.add_expressions_button.disabled = false
		
		if catalog_root.current_selected:
			expressions_menu.setup_animation_selection_ui(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"], 2)
	else:
		if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["stage_instance_path"] == "":
			expressions_menu.add_expressions_button.disabled = true
	
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_instance_path"] = text_String


func on_sprite_mask_text_entered(new_text:String) -> void:
	on_sprite_mask_text_changed(new_text)


func on_sprite_mask_text_changed(new_text:String) -> void:
	var flag : bool = false
	
	if new_text.replace(" ","") == "":
		box_sprite_preview.material.set("shader_param/mask_image", preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"))
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_image"] = "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_preset"] = 0
		
		for i in box_sprite_mask_presets.get_children():
			i.modulate = Color.white
		
		return
	
	match new_text.get_extension():
		"png", "jpg", "jpeg", "bmp":
			flag = true
	
	if flag:
		var file_check : File = File.new()
		
		if file_check.file_exists(new_text):
			box_sprite_mask_field.set("custom_colors/font_color", Color.green)
			
			box_sprite_preview.material.set("shader_param/mask_image", load(new_text))
			
			if catalog_root.current_selected:
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_image"] = new_text
			
			if catalog_root.current_selected:
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_preset"] = -1
			
		else:
			box_sprite_preview.material.set("shader_param/mask_image", preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"))
		
			if catalog_root.current_selected:
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_image"] = "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"
		
			if catalog_root.current_selected:
				catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_preset"] = 0
		
			box_sprite_mask_field.set("custom_colors/font_color", Color.red)
	
	
	for i in box_sprite_mask_presets.get_children():
		i.modulate = Color.white


func box_sprite_instance_field_color(flag:bool) -> void:
	if box_main_instance_field:
		match flag:
			true:
				(box_main_instance_field as LineEdit).set("custom_colors/font_color", Color.green)
			_:
				(box_main_instance_field as LineEdit).set("custom_colors/font_color", Color.red)


func on_box_sprite_dimension_x_value_changed(value:float) -> void:
	var old_info : Array = set_box_sprite_dimension_value(value, true)
	
	if box_sprite_dimension_x:
		if (box_sprite_dimension_x.get_line_edit() as Control).has_focus():
			adjust_other_coord_porportional(value, old_info)
	
	adjust_box_preview_dimensions()


func on_box_sprite_dimension_y_value_changed(value:float) -> void:
	var old_info : Array = set_box_sprite_dimension_value(value, false)
	
	if box_sprite_dimension_y:
		if (box_sprite_dimension_y.get_line_edit() as Control).has_focus():
			adjust_other_coord_porportional(value, old_info)
	
	adjust_box_preview_dimensions()


func on_box_sprite_dimension_x_changed() -> void:
	var value : float = (box_sprite_dimension_x as SpinBox).value
	
	var old_info : Array = set_box_sprite_dimension_value(value, true)
	
	adjust_box_preview_dimensions()


func on_box_sprite_dimension_y_changed() -> void:
	var value : float = (box_sprite_dimension_y as SpinBox).value
	
	var old_info : Array = set_box_sprite_dimension_value(value, false)
	
	adjust_box_preview_dimensions()


func on_proportional_editing_toggled(button_pressed:bool) -> void:
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_dimensions_proportional"] = button_pressed
	
	update_dimensions_ui()


func update_dimensions_ui() -> void:
	if proportional_editing:
		if (proportional_editing as TextureButton).pressed:
			
			box_sprite_dimension_x.get_line_edit().set("custom_colors/font_color", proportional_editing_linked_color)
			
			box_sprite_dimension_y.get_line_edit().set("custom_colors/font_color", proportional_editing_linked_color)
			
		else:
			box_sprite_dimension_x.get_line_edit().set("custom_colors/font_color", null)
			
			box_sprite_dimension_y.get_line_edit().set("custom_colors/font_color", null)


func on_box_sprite_transparency_toggled(button_pressed:bool) -> void:
	if catalog_root.current_selected:
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_transparent"] = button_pressed
	
	adjust_box_preview_transparency()







func setup_box_sprite_preview() -> void:
	if catalog_root.current_selected && box_sprite_preview && box_sprite_viewport:
		
		# Set viewport properties
		(box_sprite_viewport as Viewport ).size = Vector2(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_dimensions"]["x"], catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_dimensions"]["y"])
		
		(box_sprite_viewport as Viewport ).transparent_bg = catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_transparent"]
		
		# Set preview texture
		if !(box_sprite_preview as TextureRect).texture:
			(box_sprite_preview as TextureRect).texture = (box_sprite_viewport as Viewport).get_texture()


func reset_box_sprite_preview() -> void:
	if box_sprite_preview && box_sprite_viewport:
		
		# Set viewport properties
		(box_sprite_viewport as Viewport ).size = Vector2(256, 256)
		
		(box_sprite_viewport as Viewport ).transparent_bg = false
		
		# Set preview texture
		(box_sprite_preview as TextureRect).texture = null


func adjust_box_preview_dimensions() -> void:
	if box_sprite_preview && box_sprite_viewport:
		
		# Adjust preview viewport and texture
		(box_sprite_preview as TextureRect).texture = null
		
		(box_sprite_viewport as Viewport ).size = Vector2( (box_sprite_dimension_x as SpinBox).value, (box_sprite_dimension_y as SpinBox).value)
		
		(box_sprite_preview as TextureRect).texture = (box_sprite_viewport as Viewport).get_texture()
		
		
		# Adjust 2D instances
		if box_sprite_2d_container.get_child_count() > 0:
			for i in box_sprite_2d_container.get_children():
				if i is Node2D:
					
					# Position Element
					i.position = box_sprite_viewport.size * 0.5
					
					# Scale Element
					if i.has_method("get_rect"):
						i.scale = Vector2.ONE
						
						var new_scale : Vector2 = get_2D_scale_factor(i.get_rect().size)
						var scale_factor_x : float = new_scale.x / i.get_rect().size.x
						var scale_factor_y : float = new_scale.y / i.get_rect().size.y
						
						i.apply_scale(Vector2(scale_factor_x, scale_factor_y))
					
				elif i is CanvasItem:
					
					# Scale Element
					if "rect_size" in i:
						i.rect_scale = Vector2.ONE
						
						var new_scale : Vector2 = get_2D_scale_factor(i.rect_size)
						var scale_factor_x : float = new_scale.x / i.rect_size.x
						var scale_factor_y : float = new_scale.y / i.rect_size.y
						
						i.rect_scale = i.rect_scale * (Vector2(scale_factor_x, scale_factor_y))
						
					# Position Element
					i.rect_position = (box_sprite_viewport.size * 0.5) - ((i.rect_size * i.rect_scale) * 0.5)


func get_2D_scale_factor(image_dimensions:Vector2) -> Vector2:
	var viewport_size : Vector2 = box_sprite_viewport.size
	var size : Vector2
	
	var i_ratio : float = image_dimensions.x / image_dimensions.y
	var v_ratio : float = viewport_size.x / viewport_size.y
	
	if v_ratio > i_ratio:
		size = Vector2( (image_dimensions.x * viewport_size.y) / image_dimensions.y, viewport_size.y )
	else:
		size = Vector2( viewport_size.x, (image_dimensions.y * viewport_size.x) / image_dimensions.x )
	
	return size


func adjust_other_coord_porportional(value:float, old_info:Array) -> void:
	if proportional_editing:
		if proportional_editing.pressed:
			var magnitude_diff : float = value / old_info[1]
			
			var opposite_coord : bool = true if old_info[0] == "y" else false
			
			var opposite_value : float = (get_box_sprite_dimension_value( opposite_coord ) * magnitude_diff)
			
			match opposite_coord:
				true:
					(box_sprite_dimension_x as SpinBox).value = opposite_value
					set_box_sprite_dimension_value(opposite_value, opposite_coord)
				_:
					(box_sprite_dimension_y as SpinBox).value = opposite_value
					set_box_sprite_dimension_value(opposite_value, opposite_coord)
			
			adjust_box_preview_dimensions()


func adjust_box_preview_transparency() -> void:
	if box_sprite_preview && box_sprite_viewport:
		(box_sprite_viewport as Viewport ).transparent_bg = (transparency_toggle as CheckButton).pressed


func set_box_sprite_dimension_value(value:float, xy_switch:bool) -> Array:
	if catalog_root.current_selected:
		var coord : String = "x" if xy_switch else "y"
		var previous_value : float = catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_dimensions"][coord] 
		
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_dimensions"][coord] = value
	
		return [coord, previous_value]
	else:
		return [null]


func get_box_sprite_dimension_value(xy_switch:bool) -> float:
	if catalog_root.current_selected:
		var coord : String = "x" if xy_switch else "y"
		
		return catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_dimensions"][coord]
	else:
		return 1.0



func update_box_sprite_component_info(instance:Object) -> void:
	# Clear anim paths data
	clear_visual_instance_anim_path_array("box_sprite_animation_player_paths")
	clear_visual_instance_anim_path_array("box_sprite_sprite_frames_paths")
	
	# Update Node UI
	if box_sprite_display_components && box_sprite_animation_components:
		for i in box_sprite_display_components.get_children():
			i.queue_free()
		
		for i in box_sprite_animation_components.get_children():
			i.queue_free()
	
	# Add parent instance to node list
	var node : Object = instance.duplicate(true)
	var nodes_list : Array = _filter_array(_get_object_child_nodes(node))
	
	nodes_list.push_front(node)
	
#	print(nodes_list)
	
	var node_type_array : Array = []
	
	# Populate component icons
	for i in nodes_list:
		if i is Sprite:
			add_node(1, box_sprite_display_components)
			node_type_array.append("Sprite")
			
		elif i is AnimatedSprite:
			add_node(2, box_sprite_display_components)
			node_type_array.append("AnimatedSprite")
			
			add_node(9, box_sprite_animation_components)
			
			set_visual_instance_anim_path(i, node, "box_sprite_sprite_frames_paths")
			
		elif i is Sprite3D:
			add_node(4, box_sprite_display_components)
			node_type_array.append("Sprite3D")
		
		elif i is AnimatedSprite3D:
			add_node(5, box_sprite_display_components)
			node_type_array.append("AnimatedSprite3D")
		
			add_node(9, box_sprite_animation_components)
			
			set_visual_instance_anim_path(i, node, "box_sprite_sprite_frames_paths")
		
		elif i is Skeleton2D:
			add_node(3, box_sprite_display_components)
			node_type_array.append("Skeleton2D")
			
		elif i is Skeleton:
			add_node(6, box_sprite_display_components)
			node_type_array.append("Skeleton")
			
		elif i is CanvasItem:
			add_node(0, box_sprite_display_components)
			node_type_array.append("CanvasItem")
		
		elif i is AnimationTreePlayer:
			add_node(8, box_sprite_animation_components)
			node_type_array.append("AnimationTreePlayer")
		
		elif i is AnimationPlayer:
			add_node(7, box_sprite_animation_components)
			node_type_array.append("AnimationPlayer")
			
			set_visual_instance_anim_path(i, node, "box_sprite_animation_player_paths")
	
	# Setup error icons if no usuable components found
	if box_sprite_animation_components.get_child_count() <= 0:
		add_node(10, box_sprite_animation_components)
	
	if box_sprite_display_components.get_child_count() <= 0:
		add_node(10, box_sprite_display_components)
	
	# Check for multiple of the same node
	if node_type_array.size() > 0:
		for i in node_type_array:
			if node_type_array.count(i) > 1:
				
				match i:
					"CanvasItem":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 0:
								x.material.set("shader_param/multiple", true)
					"Sprite":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 1:
								x.material.set("shader_param/multiple", true)
					"AnimatedSprite":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 2:
								x.material.set("shader_param/multiple", true)
					"Sprite3D":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 4:
								x.material.set("shader_param/multiple", true)
						
					"AnimatedSprite3D":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 5:
								x.material.set("shader_param/multiple", true)
						
					"Skeleton2D":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 3:
								x.material.set("shader_param/multiple", true)
						
					"Skeleton":
						for x in box_sprite_display_components.get_children():
							if x.material.get("shader_param/index") == 6:
								x.material.set("shader_param/multiple", true)
	
	node.queue_free()



func reset_box_sprite_component_info() -> void:
	# Reset Node UI
	if box_sprite_display_components && box_sprite_animation_components:
		for i in box_sprite_display_components.get_children():
			i.queue_free()
		
		for i in box_sprite_animation_components.get_children():
			i.queue_free()
	
	
	var node_icon := node_type_icon.instance()
	
	box_sprite_display_components.add_child(node_icon)
	
	node_icon.node_type = 10
	
	
	var node_icon2 := node_type_icon.instance()
	
	box_sprite_animation_components.add_child(node_icon2)
	
	node_icon2.node_type = 10
	
	
	
	if catalog_root.current_selected:
		if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"].has_all(["box_sprite_animation_player_paths", "box_sprite_sprite_frames_paths"]):
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_animation_player_paths"].clear()
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_sprite_frames_paths"].clear()
		
		for i in catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"].keys():
			for x in catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i]:
				for y in catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i].keys():
					if y.find("box") != -1:
						if typeof(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]) == TYPE_DICTIONARY:
							if catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y].has_all(["animation_player","animation_name","animation_menu_index","animation_menu_text"]):
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_player"] = ""
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_name"] = ""
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_menu_index"] = 0
								catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["expressions"][i][y]["animation_menu_text"] = ""
		
		expressions_menu.setup_animation_selection_ui(catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"], 2)



func on_preset_button_pressed(node:Object) -> void:
	prints(node.name, " preset pressed")
	
	if node.name.to_lower() == "nomask":
		box_sprite_preview.material.set("shader_param/mask_image", preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"))
		
		(box_sprite_mask_field as LineEdit).text = ""
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_image"] = "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/full_rect_mask.png"
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_preset"] = 0
		
		(box_sprite_mask_field as LineEdit).set("custom_colors/font_color", null)
		
	else:
		(node as TextureButton).modulate = Color.green
		
		var mask_path : String = (node as TextureButton).texture_normal.resource_path
		
		(box_sprite_preview as TextureRect).material.set( "shader_param/mask_image", load( mask_path ) )
		
		(box_sprite_mask_field as LineEdit).text = mask_path
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_image"] = mask_path
		
		if catalog_root.current_selected:
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"]["box_sprite_mask_preset"] = node.get_index()
		
		(box_sprite_mask_field as LineEdit).set("custom_colors/font_color", null)
	
	for i in box_sprite_mask_presets.get_children():
		if i != node && i.name.to_lower() != "nomask":
			i.modulate = Color.white

















# Helper Methods

func setup_ui() -> void:
	get_object_ref(editor_root_path, "editor_root")
	get_object_ref(catalog_root_path, "catalog_root")
	get_object_ref(stage_character_instance_field_path, "stage_character_instance_field")
	get_object_ref(stage_instance_pos_3D_path, "stage_instance_pos_3D")
	get_object_ref(stage_instance_pos_2D_path, "stage_instance_pos_2D")
	get_object_ref(camera_path, "camera")
	get_object_ref(camera2D_path, "camera2D")
	get_object_ref(camera_slider_path, "camera_slider")
	get_object_ref(ui_bar_bg_path, "ui_bar_bg")
	get_object_ref(ui_bar_path, "ui_bar")
	get_object_ref(ui_bar_middle_path, "ui_bar_middle")
	get_object_ref(viewport_container_path, "viewport_container")
	get_object_ref(viewport_texture_path, "viewport_texture")
	get_object_ref(viewport2D_path, "viewport2D")
	get_object_ref(viewport3D_path, "viewport3D")
	get_object_ref(preview_container_path, "preview_container")
	get_object_ref(display_components_path, "display_components")
	get_object_ref(animation_components_path, "animation_components")
	get_object_ref(visual_preview_tabs_path, "visual_preview_tabs")
	get_object_ref(box_sprite_dimension_x_path, "box_sprite_dimension_x")
	get_object_ref(box_sprite_dimension_y_path, "box_sprite_dimension_y")
	get_object_ref(proportional_editing_path, "proportional_editing")
	get_object_ref(transparency_toggle_path, "transparency_toggle")
	get_object_ref(box_sprite_viewport_path, "box_sprite_viewport")
	get_object_ref(box_sprite_preview_path, "box_sprite_preview")
	get_object_ref(box_sprite_2d_container_path, "box_sprite_2d_container")
	get_object_ref(box_sprite_3d_container_path, "box_sprite_3d_container")
	get_object_ref(box_main_instance_field_path, "box_main_instance_field")
	get_object_ref(box_sprite_display_components_path, "box_sprite_display_components")
	get_object_ref(box_sprite_animation_components_path, "box_sprite_animation_components")
	get_object_ref(box_sprite_mask_field_path, "box_sprite_mask_field")
	get_object_ref(box_sprite_mask_presets_path, "box_sprite_mask_presets")
	get_object_ref(expressions_menu_path, "expressions_menu")
	
	
	$PanelContainer/VBoxContainer/HBoxContainer2/horizontal_resize4.A = $PanelContainer/VBoxContainer/HBoxContainer2/TabContainer
	$PanelContainer/VBoxContainer/HBoxContainer2/horizontal_resize4.B = $PanelContainer/VBoxContainer/HBoxContainer2/TabContainer2
	
	$PanelContainer/VBoxContainer/HBoxContainer2/horizontal_resize4._setup_init_flags()



func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )



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



func _return_nodepath(object:Object, root:Object) -> Array:
	var node_list : Array = []
	var parent : Object = object.get_parent()
	
	if parent:
		if parent != root && object != root:
			node_list.append(parent.name)
			node_list += _return_nodepath(parent, root)
	
	return node_list


func get_path_to_node(from:Object, to:Object) -> String:
	var path : String = str(from.get_path_to(to))
	return path


func set_visual_instance_anim_path(from:Object, to:Object, dictionary_key:String) -> void:
	if catalog_root.current_selected:
		if !catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"].has(dictionary_key):
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"][dictionary_key] = []
		
		var anim_names_array : PoolStringArray = []
		
		if from is AnimationPlayer:
			anim_names_array = from.get_animation_list()
		elif from is SpriteFrames:
			anim_names_array = from.get_animation_names()
		
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"][dictionary_key].append([get_path_to_node(to, from), from.name, anim_names_array])


func clear_visual_instance_anim_path_array(dictionary_key:String) -> void:
	if catalog_root.current_selected:
		if !catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"].has(dictionary_key):
			catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"][dictionary_key] = []
		
		catalog_root.character_dictionary[catalog_root.current_selected.get_text(1)]["visuals"][dictionary_key].clear()

