tool
extends PanelContainer

export(NodePath) var collapse_button_path : NodePath
var collapse_button : Object

export(NodePath) var anim_list_container_path : NodePath
var anim_list_container : Object


#var menu_anim_ready : bool = true
var menu_max_size : float = 0.0





#warnings-disable
func _ready() -> void:
	setup_ui()
	
	$Tween.connect("tween_all_completed", self, "on_menu_tween_completed")
	
	$Tween.connect("tween_started", self, "on_menu_tween_started")
	
	if collapse_button && anim_list_container:
		(collapse_button as TextureButton).connect("toggled", self, "on_collapse_button_pressed")
		
		menu_max_size = anim_list_container.rect_size.y
		
		anim_list_container.rect_min_size.y = menu_max_size
		
		collapse_menu_instant()



func collapse_menu_instant() -> void:
	collapse_button.pressed = false
	
	for i in anim_list_container.get_children():
		i.hide()
	
	anim_list_container.hide()



func on_collapse_button_pressed(pressed:bool) -> void:
	if !pressed:
		for i in anim_list_container.get_children():
			i.hide()
		
		$Tween.stop_all()
		$Tween.interpolate_property(anim_list_container, "rect_min_size", Vector2(0, menu_max_size), Vector2(0, 0), 0.08, Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$Tween.start()
	else:
		anim_list_container.show()
		
		$Tween.stop_all()
		$Tween.interpolate_property(anim_list_container, "rect_min_size", Vector2(0, 0), Vector2(0, menu_max_size), 0.08, Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$Tween.start()



func on_menu_tween_started(object:Object, key:NodePath) -> void:
	pass



func on_menu_tween_completed() -> void:
	if !collapse_button.pressed:
		anim_list_container.hide()
	else:
		for i in anim_list_container.get_children():
			i.show()












# Helper Methods

func setup_ui() -> void:
	get_object_ref(anim_list_container_path, "anim_list_container")
	get_object_ref(collapse_button_path, "collapse_button")




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

