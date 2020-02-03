tool
extends Node2D

var starting_scale : Vector2 = Vector2(1,1)

var target_scale : Vector2




#warnings-disable
func _ready() -> void:
	set_process(false)



func _process(delta: float) -> void:
	scale = scale.linear_interpolate(target_scale, delta * 10)
	
	if scale.distance_to(target_scale) < 0.01:
		set_process(false)
