tool
extends VBoxContainer


var root : Object

export(NodePath) var box_path : NodePath
var box : Object

export(NodePath) var nametag_path : NodePath
var nametag : Object

export(NodePath) var dialoguebox_path : NodePath
var dialoguebox : Object

export(NodePath) var completion_sprite_path : NodePath
var completion_sprite : Object

var name_tween : Tween = Tween.new()
var dialogue_tween : Tween = Tween.new()
var box_tween : Tween = Tween.new()
var hide_ui_tween : Tween = Tween.new()

var scene_timer : Timer = Timer.new()

var completion_timer : Timer
var completion_base_string : String = ""
var completion_indicator_state : bool = true




# Settings
export(float, 0.0, 10.0, 0.1) var dialogue_debug_auto_progress_pause : float = 0.7

export(float, 0.0, 10.0, 0.1) var box_fade_speed : float = 0.3
export(float, 0.0, 10.0, 0.1) var box_ready_pause : float = 0.2
export(float, 0.0, 10.0, 0.1) var name_fade_speed : float = 0.4
export(float, 0.0, 10.0, 0.1) var dialogue_fade_speed : float = 0.5
export(float, 0.1, 1.0, 0.1) var continue_blink_speed : float = 0.5

export(Vector2) var completion_sprite_offset : Vector2 = Vector2(35,35) setget set_completion_sprite_offset

export(String) var completion_char : String = ">"

export(StreamTexture) var completion_sprite_texture : StreamTexture

enum INDICATOR_MODE {SPRITE, CHARACTER, INLINE_SPRITE, NONE}

export(INDICATOR_MODE) var completion_mode : int = 0



# Dialogue Box FSM
var reset_on_hide : bool = false
var debug : bool = false
var packet_info : Array = []
var dialogue_box_state : String = "idle"

var state : String = ""






#warnings-disable
func _ready() -> void:
	setup_ui()
	
	add_child(name_tween)
	add_child(dialogue_tween)
	add_child(box_tween)
	add_child(hide_ui_tween)
	
	name_tween.connect("tween_all_completed", self, "_on_name_tweens_completed")
	
	dialogue_tween.connect("tween_all_completed", self, "_on_dialogue_tweens_completed")
	
	box_tween.connect("tween_all_completed", self, "_on_box_tweens_completed")
	
	hide_ui_tween.connect("tween_all_completed", self, "_on_hide_ui_tweens_completed")
	
	scene_timer.one_shot = true
	
	add_child(scene_timer)
	
	scene_timer.connect("timeout", self, "_on_scene_timer_timeout")




# Dialogue Box Finite State Machine
func start_dialogue( _name_:String, _dialogue_:String, debug_flag:bool = false ) -> void:
	packet_info = [_name_, _dialogue_]
	
	debug = debug_flag
	
	dialogue_fsm_tick()


func dialogue_fsm_tick() -> void:
	match dialogue_box_state:
		#1. Fade box in if not already visible
		"idle":
			box_ui_visibility(true)
		
		#2. Fade name in if not already visible, if visible handle name change animation if name has changed
		"fade_in_completed":
			handle_name_info()
		
		#3. Fade text in / animate text typing until dialogue is completed
		"name_set":
			handle_dialogue_info()
		
		#4. Activate end blip animation / handle input wait
		"dialogue_completed":
			if !debug:
				handle_round_completion()
			else:
				#5. If in debug mode -> emit success signal after 0.5 seconds of waiting
				handle_debug_completion()




func box_ui_visibility(visibility:bool) -> void:
	match visibility:
		true:
			if !visible:
				dialogue_box_state = "fading_in"
				
				modulate = Color(1,1,1,0)
				show()
				
				hide_ui_tween.stop_all()
				
				box_tween.stop_all()
				box_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), box_fade_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				box_tween.start()
				
#				dialogue_fsm_tick()
			else:
				if modulate.a < 1.0:
					dialogue_box_state = "fading_in"
					
					modulate = Color(1,1,1,0)
					show()
					
					hide_ui_tween.stop_all()
					
					box_tween.stop_all()
					box_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), box_fade_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					box_tween.start()
					
	#				dialogue_fsm_tick()
				else:
					hide_ui_tween.stop_all()
					
					dialogue_box_state = "fade_in_completed"
					dialogue_fsm_tick()



func handle_name_info() -> void:
	match packet_info[0].replace(" ", ""):
		"":
			nametag.bbcode_text = ""
			nametag.hide()
			
			dialogue_box_state = "name_set"
			
			dialogue_fsm_tick()
		_:
			if nametag.bbcode_text == packet_info[0]:
				clear_dialogue()
				
				nametag.show()
				nametag.modulate = Color(1,1,1,1)
				
				scene_timer.stop()
				scene_timer.wait_time = name_fade_speed * 0.5
				scene_timer.start()
				
				dialogue_box_state = "name_set"
				state = "_name_recurred"
			else:
				clear_dialogue()
				
				nametag.show()
				nametag.bbcode_text = packet_info[0]
				nametag.modulate = Color(1,1,1,0)
				
				name_tween.stop_all()
				name_tween.interpolate_property(nametag, "modulate", Color(1,1,1,0), Color(1,1,1,1), name_fade_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				name_tween.start()






func handle_dialogue_info() -> void:
	match packet_info[1].replace(" ", ""):
		"":
			dialoguebox.hide()
			dialoguebox.bbcode_text = ""
			
			dialogue_box_state = "dialogue_completed"
			dialogue_fsm_tick()
		_:
			dialoguebox.show()
			dialoguebox.bbcode_text = packet_info[1]
			dialoguebox.modulate = Color(1,1,1,0)
			
			dialogue_tween.stop_all()
			dialogue_tween.interpolate_property(dialoguebox, "modulate", Color(1,1,1,0), Color(1,1,1,1), name_fade_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			dialogue_tween.start()



func handle_round_completion() -> void:
	if root:
		dialogue_box_state = "idle"
		packet_info.clear()
		
		start_continue_indicator()
		
		if root.get_node_or_null("InputControl"):
			root.get_node("InputControl").wait_for_input()



func handle_debug_completion() -> void:
	scene_timer.stop()
	scene_timer.wait_time = dialogue_debug_auto_progress_pause
	scene_timer.start()
	
	state = "_handle_debug_completion"







func start_continue_indicator() -> void:
	match completion_mode:
		INDICATOR_MODE.SPRITE:
			if completion_sprite && completion_sprite_texture:
				completion_timer = Timer.new()
				completion_timer.wait_time = continue_blink_speed
				completion_timer.one_shot = false
				add_child(completion_timer)
				completion_timer.connect("timeout", self, "_on_completion_timeout")
				completion_timer.start()
				
				completion_sprite.texture = completion_sprite_texture
			else:
				push_warning("Completion indicator sprite and/or sprite texture is null")
		
		INDICATOR_MODE.INLINE_SPRITE:
			if completion_sprite_texture:
				completion_timer = Timer.new()
				completion_timer.wait_time = continue_blink_speed
				completion_timer.one_shot = false
				add_child(completion_timer)
				completion_timer.connect("timeout", self, "_on_completion_timeout")
				completion_timer.start()
				
				completion_base_string = dialoguebox.bbcode_text
			else:
				push_warning("Completion indicator sprite texture is null")
		
		INDICATOR_MODE.CHARACTER:
			if completion_char.replace(" ", "") != "":
				completion_timer = Timer.new()
				completion_timer.wait_time = continue_blink_speed
				completion_timer.one_shot = false
				add_child(completion_timer)
				completion_timer.connect("timeout", self, "_on_completion_timeout")
				completion_timer.start()
				
				completion_base_string = dialoguebox.bbcode_text
			else:
				push_warning("Completion indicator character string is blank")
		
		INDICATOR_MODE.NONE:
			pass
		_:
			pass


func _on_completion_timeout() -> void:
	match completion_mode:
		INDICATOR_MODE.SPRITE:
			if completion_sprite:
				match completion_indicator_state:
					true:
						completion_sprite.show()
						completion_indicator_state = false
					_:
						completion_sprite.hide()
						completion_indicator_state = true
		
		INDICATOR_MODE.INLINE_SPRITE:
			if completion_sprite_texture:
				match completion_indicator_state:
					true:
						dialoguebox.add_text(" ")
						dialoguebox.add_image(completion_sprite_texture)
						
						completion_indicator_state = false
					_:
						dialoguebox.bbcode_text = str(completion_base_string)
						
						completion_indicator_state = true
		
		INDICATOR_MODE.CHARACTER:
			if completion_char.replace(" ", "") != "":
				match completion_indicator_state:
					true:
						dialoguebox.bbcode_text = str(completion_base_string, " ", completion_char)
						
						completion_indicator_state = false
					_:
						dialoguebox.bbcode_text = str(completion_base_string)
						
						completion_indicator_state = true
		
		INDICATOR_MODE.NONE:
			pass
		_:
			pass



func stop_continue_animation():
	if completion_sprite:
		completion_sprite.hide()
	
	dialoguebox.bbcode_text = completion_base_string
	
	completion_sprite.texture = null
	
	completion_timer.stop()
	
	if completion_timer.is_connected("timeout", self, "_on_completion_timeout"):
		completion_timer.disconnect("timeout", self, "_on_completion_timeout")
		
	completion_timer.free()
	
	completion_base_string = ""
	
	completion_indicator_state = true


# Reset
#func _reset() -> void:
#	reset_on_hide = false
#	debug = false
#	packet_info = []
#	dialogue_box_state = "idle"
#	state = ""
#
#	name_tween.reset_all()
#	dialogue_tween.reset_all()
#	box_tween.reset_all()
#	hide_ui_tween.reset_all()
#	scene_timer.stop()
#
#	hide()
#
#	if nametag is RichTextLabel:
#		nametag.bbcode_text = ""
#		nametag.modulate = Color(1,1,1,0)
#		nametag.hide()
#
#	if dialoguebox is RichTextLabel:
#		dialoguebox.bbcode_text = ""
#		dialoguebox.modulate = Color(1,1,1,0)
#		dialoguebox.hide()




# Tween functions
func _on_name_tweens_completed() -> void:
	if nametag.modulate.a == 0.0:
		nametag.hide()
		clear_name()
	else:
		dialogue_box_state = "name_set"
		dialogue_fsm_tick()

func _on_dialogue_tweens_completed() -> void:
	if dialoguebox.modulate.a == 0.0:
		dialoguebox.hide()
	else:
		dialogue_box_state = "dialogue_completed"
		dialogue_fsm_tick()

func _on_box_tweens_completed() -> void:
	if modulate.a == 0.0:
		hide()
		dialogue_box_state = "idle"
	else:
		scene_timer.stop()
		scene_timer.wait_time = box_ready_pause
		scene_timer.start()
		
		
		dialogue_box_state = "fade_in_completed"
		state = "_on_box_tweens_completed"


func _on_hide_ui_tweens_completed() -> void:
	if modulate.a == 0.0:
		if reset_on_hide:
#			_reset()
			clear_name()
			clear_dialogue()
		if root:
			if root.debug_mode:
				scene_timer.stop()
				scene_timer.wait_time = box_ready_pause
				scene_timer.start()
				
				state = "yield_emit_success"
			else:
				scene_timer.stop()
				scene_timer.wait_time = box_ready_pause
				scene_timer.start()
				
				state = "yield_emit_success"
	else:
		if root:
			if root.debug_mode:
				scene_timer.stop()
				scene_timer.wait_time = box_ready_pause
				scene_timer.start()
				
				state = "yield_emit_success"
			else:
				scene_timer.stop()
				scene_timer.wait_time = box_ready_pause
				scene_timer.start()
				
				state = "yield_emit_success"




func _on_scene_timer_timeout() -> void:
	match state:
		"_on_box_tweens_completed":
			dialogue_fsm_tick()
		
		"_name_recurred":
			dialogue_fsm_tick()
		
		"_handle_debug_completion":
			if root:
				dialogue_box_state = "idle"
				packet_info.clear()
				state = ""
				
				root.emit_signal("success")
		
		"yield_emit_success":
			root.emit_signal("success")










# Dialogue container functions
func set_box_visibility(flag:bool) -> void:
	match flag:
		true:
			hide_ui_tween.stop_all()
			hide_ui_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), box_fade_speed * 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			hide_ui_tween.start()
		_:
			hide_ui_tween.stop_all()
			hide_ui_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0), box_fade_speed * 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			hide_ui_tween.start()




# DialogueBox functions
func clear_dialogue() -> void:
	if dialoguebox is RichTextLabel:
		dialoguebox.bbcode_text = ""
		dialoguebox.hide()




# Nametag functions
func clear_name() -> void:
	if nametag is RichTextLabel:
		nametag.bbcode_text = ""
		nametag.hide()

func set_name(_name_:String) -> void:
	if !visible:
		show()
	
	if nametag is RichTextLabel:
		if _name_ == nametag.bbcode_text:
			pass
		elif _name_ != nametag.bbcode_text:
			nametag.modulate = Color(1.0, 1.0, 1.0, 0.0)
			nametag.show()
			
			dialogue_tween.stop_all()
			dialogue_tween.interpolate_property( nametag, "modulate", nametag.modulate, Color.white, name_fade_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT )
			dialogue_tween.start()

func hide_name(fadeout:bool = true) -> void:
	if !fadeout:
		nametag.modulate = Color(1.0, 1.0, 1.0, 0.0)
		clear_name()
	else:
		dialogue_tween.stop_all()
		dialogue_tween.interpolate_property( nametag, "modulate", nametag.modulate, Color( 1.0, 1.0, 1.0, 0.0 ), name_fade_speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT )
		dialogue_tween.start()











# Helper Methods
func setup_ui() -> void:
	root = get_parent().get_parent().get_parent()
	
	get_object_ref(nametag_path, "nametag")
	get_object_ref(dialoguebox_path, "dialoguebox")
	get_object_ref(box_path, "box")
	get_object_ref(completion_sprite_path, "completion_sprite")
	
	if box:
		(box as CanvasItem).connect("item_rect_changed", self, "_on_Container_resized")

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )









func set_completion_sprite_offset(new_offset:Vector2) -> void:
	completion_sprite_offset = new_offset
	
	if completion_sprite && box:
		var end_coord : Vector2 = Vector2.ZERO
		
		if box is Control:
			end_coord = (box as CanvasItem).get_canvas_transform().get_origin() + (box as Control).rect_size
		elif box is Sprite:
			end_coord = (box as Sprite).position + (box as Sprite).texture.get_size() * (box as Sprite).scale
		
		if completion_sprite is Node2D:
			(completion_sprite as Node2D).position = end_coord - completion_sprite_offset
		elif completion_sprite is Control:
			(completion_sprite as Control).rect_position = end_coord - completion_sprite_offset
		


func _on_Container_resized() -> void:
	if completion_sprite && box:
		var end_coord : Vector2 = Vector2.ZERO
		
		if box is Control:
			end_coord = (box as CanvasItem).get_canvas_transform().get_origin() + (box as Control).rect_size
		elif box is Sprite:
			end_coord = (box as Sprite).position + (box as Sprite).texture.get_size() * (box as Sprite).scale
		
		if completion_sprite is Node2D:
			(completion_sprite as Node2D).position = end_coord - completion_sprite_offset
		elif completion_sprite is Control:
			(completion_sprite as Control).rect_position = end_coord - completion_sprite_offset
