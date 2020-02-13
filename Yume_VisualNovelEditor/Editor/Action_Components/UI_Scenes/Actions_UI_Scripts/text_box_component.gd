tool
extends HBoxContainer

onready var node_container_base : Object = $"../../../../.."
onready var action_node_root : Object = $"../../../../../.."

#internal
var mouse_over : bool = false

var dialogue_string : String = ""
var placeholder_text : String = ""
var use_placeholder_text : bool = false




#warnings-disable
func _ready() -> void:
	set_meta("text_box_component", true)
	
	# preview initialization
	
	
	# customize node ui based on action name
	match action_node_root.action_title:
		"Expressed Line":
			$VBoxContainer2/HBoxContainer/Label.text = "Dialogue Text"
			node_container_base.character_dialogue_preview = true
			$VBoxContainer2/HBoxContainer/VBoxContainer/variables_list.hide()
	
	# handle load data
	if action_node_root.loaded_action_data:
		if action_node_root.loaded_action_data.has("text_box"):
			dialogue_string = action_node_root.loaded_action_data["text_box"][0]
			
			$VBoxContainer2/HBoxContainer/LineEdit.text = action_node_root.loaded_action_data["text_box"][0]
			
			node_container_base.set_dialogue_text(action_node_root.loaded_action_data["text_box"][0])
			
			if action_node_root.loaded_action_data["text_box"][1]:
				use_placeholder_text = action_node_root.loaded_action_data["text_box"][1]
				
				$VBoxContainer2/HBoxContainer/CheckButton.pressed = true
				
				$VBoxContainer2/HBoxContainer/VBoxContainer.hide()
				$VBoxContainer2/HBoxContainer/LineEdit.hide()
				$VBoxContainer2/HBoxContainer/PlaceholderText.show()
				
				$VBoxContainer2/HBoxContainer/PlaceholderText.text = action_node_root.loaded_action_data["text_box"][2]
				
				node_container_base.set_dialogue_text(action_node_root.loaded_action_data["text_box"][2], true)
				
			placeholder_text = action_node_root.loaded_action_data["text_box"][2]




# Main Action Info
func get_action_data() -> Array:
	return [dialogue_string, use_placeholder_text, placeholder_text]




func _on_CheckButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		use_placeholder_text = true
		
		$VBoxContainer2/HBoxContainer/VBoxContainer.hide()
		$VBoxContainer2/HBoxContainer/LineEdit.hide()
		$VBoxContainer2/HBoxContainer/PlaceholderText.show()
		
		var line : String = generate_placeholder_text()
		placeholder_text = line
		$VBoxContainer2/HBoxContainer/PlaceholderText.text = line
		
		node_container_base.set_dialogue_text(line, true)
	else:
		use_placeholder_text = false
		
		$VBoxContainer2/HBoxContainer/VBoxContainer.show()
		$VBoxContainer2/HBoxContainer/LineEdit.show()
		$VBoxContainer2/HBoxContainer/PlaceholderText.hide()
		
		node_container_base.set_dialogue_text(dialogue_string)


func _on_LineEdit_text_changed() -> void:
	dialogue_string = $VBoxContainer2/HBoxContainer/LineEdit.text
	node_container_base.set_dialogue_text($VBoxContainer2/HBoxContainer/LineEdit.text)

func _on_LineEdit_request_completion() -> void:
	dialogue_string = $VBoxContainer2/HBoxContainer/LineEdit.text
	node_container_base.set_dialogue_text($VBoxContainer2/HBoxContainer/LineEdit.text)





func generate_placeholder_text() -> String:
	var rand = randi() % 11
	
	match rand:
		0:
			return "There are plenty of people in Avonlea and out of it, who can attend closely to their neighbor's business by dint of neglecting their own; but Mrs. Rachel Lynde was one of those capable creatures who can manage their own concerns and those of other folks into the bargain."
		1:
			return '"Good evening, Rachel," Marilla said briskly. "This is a real fine evening, isn\'t it?  Won\'t you sit down?  How are all your folks?"'
		2:
			return '"Oh, I\'m very glad you\'ve come, even if it would have been nice to sleep in a wild cherry-tree.  We\'ve got to drive a long piece haven\'t we?  Mrs. Spencer said it was eight miles."'
		3:
			return '"I\'m so glad it\'s a sunshiny morning.  But I like rainy mornings real well too.  All sorts of mornings are interesting, don\'t you think?"'
		4:
			return '"Oh, what I KNOW about myself isn\'t really worth telling."'
		5:
			return '"No, I don\'t want any of your imaginings.  Just you stick to bald facts.  Begin at the beginning."'
		6:
			return '"I think you\'d better learn to control that imagination of yours, Anne, if you can\'t distinguish between what is real and what isn\'t." said Marilla crossly.'
		7:
			return '"I did feel a little that way, too," said Anne.  "I kind of felt I shouldn\'t shorten their lovely lives by picking them - I wouldn\'t want to be picked if I were an apple blossom."'
		8:
			return "Anne sighed, retreated to the east gable, and sat down in a chair by the window."
		9:
			return '"I\'m not feeling discouraged," was Marilla\'s dry response, "when I make up my mind to do a thing it stays made up."'
		_:
			return '"I apologized pretty well, didn\'t I?" she said proudly as they went down the lane. "I thought since I had to do it I might as well do it thoroughly."'











func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed && !mouse_over:
			mouse_over = true
			$VBoxContainer2/HBoxContainer/LineEdit.release_focus()
			set_process_input(false)
	elif event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER):
			$VBoxContainer2/HBoxContainer/LineEdit.release_focus()
			mouse_over = true
			set_process(false)

func _on_LineEdit_focus_entered() -> void:
	set_process_input(true)

func _on_LineEdit_mouse_entered() -> void:
	mouse_over = true

func _on_LineEdit_mouse_exited() -> void:
	mouse_over = false
