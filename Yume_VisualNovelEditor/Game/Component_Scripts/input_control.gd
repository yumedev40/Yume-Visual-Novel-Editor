tool
extends Node

onready var root := $".."

var timer : Timer




#warnings-disable
func _ready() -> void:
	set_process_input(false)

func _reset() -> void:
	set_process_input(false)
	
	if is_instance_valid(timer):
		timer.stop()
		timer.disconnect("timeout", self, "_on_wait_timeout")
		timer.free()



func wait_for_time(length:float) -> void:
	if length > 0.0:
		timer = Timer.new()
		add_child(timer)
		timer.connect("timeout", self, "_on_wait_timeout")
		
		timer.stop()
		timer.wait_time = length
		timer.start()
	else:
		root.emit_signal("success")

func wait_for_input() -> void:
	if !root.debug_mode:
		set_process_input(true)
	else:
		push_warning("Waiting for input is not supported in preview mode")
		root.emit_signal("failure")


func _on_wait_timeout() -> void:
#	timer.call_deferred("disconnect", "timeout", self, "_on_wait_timeout")
	timer.queue_free()
	root.emit_signal("success")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			for i in root.get_node("UI_COMPONENTS/DialogueBox_UI").get_children():
				if i.has_method("stop_continue_animation"):
					i.stop_continue_animation()
			
			root.emit_signal("success")
			set_process_input(false)
	
	if OS.has_touchscreen_ui_hint():
		if event is InputEventScreenTouch:
			if event.pressed:
				for i in root.get_node("UI_COMPONENTS/DialogueBox_UI").get_children():
					if i.has_method("stop_continue_animation"):
						i.stop_continue_animation()
				
				root.emit_signal("success")
				set_process_input(false)
