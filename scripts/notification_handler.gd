extends Control

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().current_scene.name == "Home":
			get_tree().quit()
		else:
			get_tree().change_scene_to_file("res://scenes/home.tscn")
