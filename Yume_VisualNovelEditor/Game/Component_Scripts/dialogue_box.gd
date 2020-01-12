tool
extends VBoxContainer

var root : Object

export(NodePath) var nametag_path : NodePath
var nametag : Object

export(NodePath) var dialoguebox_path : NodePath
var dialoguebox : Object

var name_tween : Tween = Tween.new()
var dialogue_tween : Tween = Tween.new()
var box_tween : Tween = Tween.new()


# Internal Variables
var name_fade_speed : float = 0.0
var dialogue_fade_speed : float = 0.0

# Dialogue Box FSM
var dialogue_box_state : String = "Idle"

var fsm_func_state : GDScriptFunctionState







#warnings-disable
func _ready() -> void:
	setup_ui()
	
	add_child(name_tween)
	add_child(dialogue_tween)
	add_child(box_tween)
	
	name_tween.connect("tween_all_completed", self, "_on_name_tweens_completed")
	
	dialogue_tween.connect("tween_all_completed", self, "_on_dialogue_tweens_completed")
	
	box_tween.connect("tween_all_completed", self, "_on_box_tweens_completed")




# Dialogue Box Finite State Machine
func start_dialogue( _name_:String, _dialogue_:String ) -> void:
	pass
	
	#1. Fade box in if not already visible
	
	# (yield, signal)
	
	#2. Fade name in if not already visible, if visible handle name change animation if name has changed
	
	# (yield)
	
	#3. Fade text in / animate text typing until dialogue is completed
	
	# (yield)
	
	#4. Activate end blip animation / handle input wait
	
	# (yield)
	
	#5. If in debug mode -> emit success signal after 0.5 seconds of waiting



#1
func box_ui_visibility() -> void:
	pass


#2
func handle_name_info() -> void:
	pass


#3
func handle_dialogue_info() -> void:
	pass


#4
func handle_round_completion() -> void:
	# End blip
	# Progression
	pass


#5
func handle_debug_completion() -> void:
	pass








# Reset
func _reset() -> void:
	name_tween.stop_all()
	dialogue_tween.stop_all()
	
	hide()
	
	if nametag is RichTextLabel:
		nametag.bbcode_text = ""
		nametag.hide()
	
	if dialoguebox is RichTextLabel:
		dialoguebox.bbcode_text = ""
		dialoguebox.hide()




# Tween functions
func _on_name_tweens_completed() -> void:
	if nametag.modulate.a == 0.0:
		nametag.hide()
		clear_name()

func _on_dialogue_tweens_completed() -> void:
	if dialoguebox.modulate.a == 0.0:
		dialoguebox.hide()

func _on_box_tweens_completed() -> void:
	if modulate.a == 0.0:
		hide()




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

func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )
