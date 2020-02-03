tool
extends TextureRect

enum NODE {TEXTURE_RECT, SPRITE2D, ANIMATED_SPRITE2D, SKELETON2D, SPRITE3D, ANIMATED_SPRITE3D, SKELETON3D, ANIMATION_PLAYER, SPRITE_FRAMES, ERROR}

export(int, 0, 9) var node_type : int = 0 setget set_node_type, get_node_type
export(bool) var multiple : bool = false setget set_multiple_nodes_flag, get_multiple_nodes_flag




#warings-disable
func _ready() -> void:
	pass



func set_node_type(type:int) -> void:
	node_type = type
	
	material.set("shader_param/index", type)

func get_node_type() -> int:
	return node_type

func set_multiple_nodes_flag(flag:bool) -> void:
	multiple = flag
	
	material.set("shader_param/multiple", flag)

func get_multiple_nodes_flag() -> bool:
	return multiple
