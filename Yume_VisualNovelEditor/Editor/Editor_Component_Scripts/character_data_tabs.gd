tool
extends TabContainer






#warnings-disable
func _ready() -> void:
	connect("tab_changed", self, "_on_tab_changed")



func _on_tab_changed(tab:int) -> void:
	var tab_selected : String = get_tab_title(tab)
	match tab_selected:
		"Visuals":
			if $Visuals.preview_container:
				$Visuals.preview_container.size_flags_stretch_ratio = $Visuals.preview_container.size_flags_stretch_ratio + 0.1
				yield(get_tree().create_timer(0.001),"timeout")
				$Visuals.preview_container.size_flags_stretch_ratio = $Visuals.preview_container.size_flags_stretch_ratio - 0.1
