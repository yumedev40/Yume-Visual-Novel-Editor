tool
extends MenuButton






# warnings-disabled
func _ready() -> void:
	connect("pressed", get_owner(), "on_character_list_selected")
	get_popup().connect("id_pressed", get_owner(), "on_character_list_item_chosen", [get_popup()])


func update_character_list(use_scene_info:bool = false) -> Dictionary:
	if !use_scene_info:
		var character_info : Dictionary = get_owner().scene_action_container.editor_root.editor_root.get_parent().get_node("Character Catalog").character_dictionary
		
		get_popup().clear()
		
		for x in   get_popup().get_children():
			if x is PopupMenu:
				x.free()
		
		for c in character_info:
			if character_info[c]["profile"]["aliases"].size() <= 0:
				get_popup().add_item(character_info[c]["profile"]["name"])
				
				get_popup().set_item_metadata(  get_popup().get_item_count() - 1, c)
				get_popup().set_item_tooltip(  get_popup().get_item_count() - 1, c)
			else:
				var alias_menu : PopupMenu = PopupMenu.new()
				alias_menu.name = character_info[c]["profile"]["name"]
				
				get_popup().add_child(alias_menu)
				alias_menu.connect("id_pressed", get_owner(), "on_alias_submenu_item_chosen", [alias_menu])
				
				get_popup().add_submenu_item(character_info[c]["profile"]["name"], character_info[c]["profile"]["name"])
				get_popup().set_item_metadata(  get_popup().get_item_count() - 1, c)
				get_popup().set_item_tooltip(  get_popup().get_item_count() - 1, c)
				
				
				alias_menu.add_item(character_info[c]["profile"]["name"])
				alias_menu.set_item_metadata(alias_menu.get_item_count() - 1, c)
				
				for a in character_info[c]["profile"]["aliases"]:
					alias_menu.add_item(a)
					alias_menu.set_item_metadata(alias_menu.get_item_count() - 1, c)
		
		return character_info
	else:
		var CADM: Object = get_owner().scene_action_container.get_node("CharacterActionsDataManager")
		
		var character_info : Dictionary = get_owner().scene_action_container.editor_root.editor_root.get_parent().get_node("Character Catalog").character_dictionary
		
		get_popup().clear()
		
		for x in get_popup().get_children():
			if x is PopupMenu:
				x.free()
		
		for c in character_info:
			
			for z in CADM.stage_state_list.size():
				if CADM.character_event_tracker[z] == get_owner().action_node_root:
					if z > 0:
						for x in CADM.stage_state_list[z - 1][1].size():
							
							if CADM.stage_state_list[z - 1][1][x][2] == c:
								var stage_rid : String = CADM.stage_state_list[z - 1][1][x][0]
								var alias_id : int = -1
								
								if character_info[c]["profile"]["aliases"].size() > 0:
									for a in character_info[c]["profile"]["aliases"].size():
										if CADM.stage_state_list[z - 1][1][x][1] == character_info[c]["profile"]["aliases"][a]:
											alias_id = a
								
								get_popup().add_item(CADM.stage_state_list[z - 1][1][x][1])
								
								get_popup().set_item_metadata( get_popup().get_item_count() - 1, [stage_rid, alias_id] )
								get_popup().set_item_tooltip( get_popup().get_item_count() - 1, stage_rid )
									
									
									
									
									
									
									
#							if character_info[c]["profile"]["aliases"].size() <= 0:
#								get_popup().add_item(character_info[c]["profile"]["name"])
#
#								get_popup().set_item_metadata(  get_popup().get_item_count() - 1, stage_rid)
#								get_popup().set_item_tooltip(  get_popup().get_item_count() - 1, stage_rid)
#							else:
#								var alias_menu : PopupMenu = PopupMenu.new()
#								alias_menu.name = character_info[c]["profile"]["name"]
#
#								get_popup().add_child(alias_menu)
#								alias_menu.connect("id_pressed", get_owner(), "on_alias_submenu_item_chosen", [alias_menu])
#
#								get_popup().add_submenu_item(character_info[c]["profile"]["name"], character_info[c]["profile"]["name"])
#								get_popup().set_item_metadata(  get_popup().get_item_count() - 1, stage_rid)
#								get_popup().set_item_tooltip(  get_popup().get_item_count() - 1, stage_rid)
#
#
#								alias_menu.add_item(character_info[c]["profile"]["name"])
#								alias_menu.set_item_metadata(alias_menu.get_item_count() - 1, stage_rid)
#
#								for a in character_info[c]["profile"]["aliases"]:
#									alias_menu.add_item(a)
#									alias_menu.set_item_metadata(alias_menu.get_item_count() - 1, stage_rid)
		
		return character_info

