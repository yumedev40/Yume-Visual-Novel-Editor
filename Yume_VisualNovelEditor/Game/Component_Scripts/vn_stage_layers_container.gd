tool
extends Spatial

var scale_unit : float = 0.0 setget set_scale_unit, get_scale_unit

export(NodePath) var cam_path : NodePath
var cam : Object

export(NodePath) var reference_point_path : NodePath
var reference_point : Object

# Internal vars
var cam_origin_position : Vector3

var pixel_scale_base : float



#warnings-disable
func _ready() -> void:
	get_object_ref(cam_path, "cam")
	get_object_ref(reference_point_path, "reference_point")
	
	if cam is Camera:
		if "pixel_size" in reference_point:
			var base_distance : float = cam.global_transform.origin.distance_to(reference_point.global_transform.origin)
			
			var pixel_size_reference : float = reference_point.pixel_size
			
			self.scale_unit = pixel_size_reference / base_distance
			pixel_scale_base = scale_unit
		else:
			push_warning("The provided reference point is not a spatial class object or does not have a pixel size to derive an adjusted distance unit from")
		
		cam_origin_position = cam.global_transform.origin
	else:
		push_warning("The provided vn stage cam object is not a camera, unable to set up a pixel distance measurement")
	
	if scale_unit > 0.0:
		distribute_layers()
		resize_layers()



func set_scale_unit(measurement:float) -> void:
	scale_unit = measurement

func get_scale_unit() -> float:
	return scale_unit





func distribute_layers() -> void:
	var start : Object = get_child(0)
	var end : Object = get_child(get_child_count() - 1)
	
	var start_depth : float = start.global_transform.origin.z
	
	var total_distance : float = start.global_transform.origin.distance_to(end.global_transform.origin)
	
	var segment_length : float = total_distance / float(get_child_count() - 1)
	
	for i in get_child_count():
		if !get_child(i) == start && !get_child(i) == end:
			if "global_transform" in get_child(i):
				get_child(i).global_transform.origin.z = start_depth + (segment_length * i)


func resize_layers() -> void:
	var sprites_list : Array = get_all_sprites(self, self)
	
	for i in sprites_list.size():
		var distance : float = cam.global_transform.origin.distance_to(sprites_list[i].global_transform.origin)
		
		sprites_list[i].pixel_size = distance * scale_unit





# Helper Methods

func get_all_sprites(node:Object, root:Object) -> Array:
	var sprite_array : Array = []
	
	for i in node.get_children():
		if "pixel_size" in i:
			sprite_array.append(i)
		
		if i.get_child_count() > 0:
			sprite_array.append(get_all_sprites(i, root))
	
	if node == root:
		var results : Array = []
		
		for i in sprite_array.size():
			if typeof(sprite_array[i]) == TYPE_ARRAY:
				for x in sprite_array[i].size():
					if !results.has(sprite_array[i][x]):
						results.append(sprite_array[i][x])
			elif !results.has(sprite_array[i]):
				results.append(sprite_array[i])
		
		return results
	else:
		return sprite_array


func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
