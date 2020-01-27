tool
extends TabContainer

var resume_preview : bool = false

#warnings-disable
func _ready() -> void:
	connect("tab_changed", self, "_on_tab_changed")

func _on_tab_changed(tab:int) -> void:
	match get_tab_title(tab):
		"Menu List":
			get_node("Menu List")._refresh_list()
			
			get_node("Menu List")._nothing_selected()
			get_node("Character Catalog").on_nothing_selected()
			
			match get_node("Story Editor").preview.preview_state:
				1,2:
					get_node("Story Editor").preview.pause_preview_button.pressed = true
					get_node("Story Editor").preview._pause_preview()
					resume_preview = true
		
		"Story Editor":
			get_node("Menu List")._nothing_selected()
			get_node("Character Catalog").on_nothing_selected()
			
			if get_node("Story Editor").preview.preview_state == 3 && resume_preview:
				get_node("Story Editor").preview.pause_preview_button.pressed = false
				get_node("Story Editor").preview._pause_preview()
				resume_preview = false
		
		"Character Catalog":
			get_node("Menu List")._nothing_selected()
			get_node("Character Catalog").on_nothing_selected()
			
			match get_node("Story Editor").preview.preview_state:
				1,2:
					get_node("Story Editor").preview.pause_preview_button.pressed = true
					get_node("Story Editor").preview._pause_preview()
					resume_preview = true
		
#		_:
#			get_node("Menu List")._nothing_selected()
