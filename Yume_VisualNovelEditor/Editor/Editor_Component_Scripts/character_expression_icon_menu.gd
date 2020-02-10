tool
extends MenuButton

export(NodePath) var icon_preview_path : NodePath
var icon_preview : Object


var menu : PopupMenu

signal icon_selected





# warnings-disable
func _ready() -> void:
	setup_ui()
	
	menu = get_popup()
	
	menu.clear()
	
	for i in menu.get_children():
		i.queue_free()
	
	menu.submenu_popup_delay = 0.1
	
	menu.connect("id_pressed", self, "on_menu_id_pressed", [menu])
	
	
	
	menu.add_icon_item(preload("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/NoIcon.png"), "No Icon")
	
	# Expression Submenus
	#-------------
	
	
	add_submenu("Neutral", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Neutral"))
	
	
	add_submenu("Happy", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Happy"))
	
	
	add_submenu("Upset", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Upset"))
	
	
	add_submenu("Disgust", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/disgust"))
	
	
	add_submenu("Fear", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Fear"))
	
	
	add_submenu("Surprised", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Surprise"))
	
	
	add_submenu("Angry", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Anger"))
	
	
	add_submenu("Playful", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Playful"))
	
	
	add_submenu("Romance", return_image_files("res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/Romance"))



func add_submenu(category_name:String, icon_list:Array) -> void:
	# Create New PopupMenu
	var new_submenu : PopupMenu = PopupMenu.new()
	new_submenu.name = category_name
	
	# Populate Expression Buttons
	for i in icon_list:
		new_submenu.add_icon_item( load(i), "")
	
	# Add Submenu
	menu.add_child(new_submenu)
	menu.add_submenu_item( str(category_name) , category_name)
	
	new_submenu.connect("id_pressed", self, "on_menu_id_pressed", [new_submenu])



func on_menu_id_pressed(idx:int, menu_item:Object) -> void:
	var icon_path : String = (menu_item as PopupMenu).get_item_icon(idx).resource_path
	
	if menu_item == menu && idx == 0:
		icon_path = "res://addons/Yume_VisualNovelEditor/Editor/Editor_UI_Images/Expressions_Icons/empty_icon.png"
	
	emit_signal("icon_selected", icon_path)
	
	if icon_preview:
		(icon_preview as TextureRect).texture = load(icon_path)
















# Helper Methods

func setup_ui() -> void:
	get_object_ref(icon_preview_path, "icon_preview")



func get_object_ref(path:NodePath, ref_var:String) -> void:
	if get_node_or_null(path):
		set( ref_var, get_node_or_null(path) )



func return_image_files(dir_path:String) -> Array:
	var image_array : Array = []
	
	var dir_check : Directory = Directory.new()
	
	if dir_check.dir_exists(dir_path):
		dir_check.open(dir_path)
		dir_check.list_dir_begin(false, true)
		var file : String = dir_check.get_next()
		
		while file != "":
			match file.get_extension():
				"png", "jpg", "jpeg", "bmp":
					var path_adjust : String = str(dir_path, "/", file.replace("res://",""))
					
					image_array.append(path_adjust)
			
			file = dir_check.get_next()
		
		dir_check.list_dir_end()
	
	return image_array
