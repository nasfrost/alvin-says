extends Panel

func _ready():
	if FileAccess.file_exists(global.highscore_path):
		var file = FileAccess.open(global.highscore_path, FileAccess.READ)
		var data = file.get_as_text()
		file.close()
	
		if data.is_valid_int():
			global.highscore = int(data)
	else:
		var file = FileAccess.open(global.highscore_path, FileAccess.WRITE)
		file.store_string(str(global.highscore))
		file.close()
	$score_container/score.text = str(global.highscore).pad_zeros(3)
	
	var title = $title
	title.pivot_offset = title.size / 2
	
	var tween = create_tween().set_loops()
	
	tween.tween_property(title, "scale", Vector2(1.08, 1.08), 2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(title, "scale", Vector2(1, 1), 2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
