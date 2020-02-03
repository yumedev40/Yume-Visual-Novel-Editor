tool
extends Camera

export(Color) var env_color : Color = Color.gray setget set_env_color

export(Color) var grid_color : Color = Color.gray setget set_grid_color

export(float, 0.1, 100, 0.1) var grid_scale : float = 80 setget set_grid_scale

#internal
var starting_pos : float = 0.0
var pos_target : float = 0.0



#warnings-disable
func _ready() -> void:
	set_env_color(env_color)
	
	starting_pos = global_transform.origin.z
	
	set_process(false)



func _process(delta: float) -> void:
	global_transform.origin.z = lerp(global_transform.origin.z, starting_pos - pos_target, delta * 10)
	
	if global_transform.origin.distance_to( Vector3(global_transform.origin.x, global_transform.origin.y, pos_target) ) < 0.01:
		set_process(false)



func set_env_color(new_color:Color) -> void:
	env_color = new_color
	
	environment.background_color = new_color
	
	environment.fog_color = new_color
	
	if get_parent():
		if get_parent().get_node_or_null("MeshInstance"):
			(get_parent().get_node("MeshInstance") as MeshInstance).material_override.set("shader_param/bg_color", new_color)


func set_grid_color(new_color:Color) -> void:
	grid_color = new_color
	
	if get_parent():
		if get_parent().get_node_or_null("MeshInstance"):
			(get_parent().get_node("MeshInstance") as MeshInstance).material_override.set("shader_param/grid_color", new_color)



func set_grid_scale(new_scale:float) -> void:
	grid_scale = new_scale
	
	if get_parent():
		if get_parent().get_node_or_null("MeshInstance"):
			(get_parent().get_node("MeshInstance") as MeshInstance).material_override.set("shader_param/grid_scale", new_scale)
