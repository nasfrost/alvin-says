extends Panel

@onready var input_buttons = [
		$button_grid/button_ne,
		$button_grid/button_nw,
		$button_grid/button_se,
		$button_grid/button_sw
	]

var nut_texture = preload("res://images/nut.png")

var highscore_achieved = false
var score = 0
var correct

func _ready():
	$labels.visible = true
	$veil.visible = false
	
	var message = $message
	message.text = ""
	message.scale = Vector2.ZERO
	
	var tween = create_tween()
	var sequence = ["Ready...", "Set...", "Go!"]
	var duration = 0.8
	
	for word in sequence:
		tween.tween_callback(func():
			message.text = word
			message.pivot_offset = message.size / 2
			message.scale = Vector2.ZERO
			message.modulate.a = 1
		)
		
		tween.tween_property(message, "scale", Vector2(1, 1), duration)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		if word != sequence[-1]:
			tween.tween_interval(duration)
			tween.parallel().tween_property(message, "scale", Vector2.ZERO, duration)
			tween.parallel().tween_property(message, "modulate:a", 0, duration)
	
	tween.tween_callback(func(): start_round(true))
	
	tween.tween_interval(duration)
	tween.tween_property(message, "modulate:a", 0, duration)

func _process(_delta: float):
	var nut_count = ceil($timer.time_left / $timer.wait_time * 6)
	var nut_container = $labels/nut_container
	
	for child in nut_container.get_children():
		child.queue_free()
		
	for n in range(nut_count):
		var nut = TextureRect.new()
		nut.texture = nut_texture
		
		nut.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		nut.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		nut.custom_minimum_size = Vector2(160, 160) * 0.25
		
		nut_container.add_child(nut)
	
func start_round(first_round: bool = false):
	$labels/score.text = "Score: " + str(score).pad_zeros(3)
	randomize()
	
	var order = [0, 1, 2, 3]
	order.shuffle()
	
	for i in range(4):
		if first_round:
			input_buttons[i].pressed.connect(_on_input_button_pressed.bind(input_buttons[i]))
		else:
			input_buttons[i].theme_type_variation = "input_button_" + str(order[i])
	
	var instructions = ["Alvin", "Simon", "Theodore", "None"]
	var instruction = instructions.pick_random()
	
	var colors = get_meta("colors")
	var written_color = colors.pick_random()
	var text_color = colors.pick_random()
	
	var command = $labels/command
	if instruction == "None":
		command.text = "Press " + written_color.to_upper() + "!"
	else:
		command.text = instruction + " says press " + written_color.to_upper() + "!"
	command.theme_type_variation = "command_" + str(colors.find(text_color))
	
	correct = []
	match instruction:
		"Alvin":
			correct.append(colors.find(text_color))
		"Simon":
			correct.append(colors.find(written_color))
		"Theodore":
			correct = [0, 1, 2, 3]
			correct.erase(colors.find(text_color))
			correct.erase(colors.find(written_color))
			
	if first_round:
		$timer.wait_time = $timer.wait_time + 0.5
	$timer.start()

func _on_input_button_pressed(button_pressed: Button):
	var i = str(button_pressed.theme_type_variation)[-1]
	if int(i) in correct:
		advance()
	else:
		game_over()

func _on_timer_timeout():
	if correct == []:
		advance()
	else:
		game_over()
		
func advance():
	var sprite = $labels_bg/sprite
	var tween = create_tween()
	var original_pos = sprite.position
	
	tween.tween_property(sprite, "position:y", original_pos.y - 40, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(sprite, "position:y", original_pos.y, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	score += 1
	if score > global.highscore:
		if global.highscore == 0:
			highscore_achieved = true
		if not highscore_achieved:
			var message = $message
			message.text = "High Score!"
			message.force_update_transform()
			message.pivot_offset = message.size / 2
			message.scale = Vector2.ZERO
			message.modulate.a = 1
			
			tween = create_tween()
			var duration = 1
			
			tween.tween_property(message, "scale", Vector2(1, 1), duration)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				
			tween.tween_interval(duration * 5)
			
			tween.parallel().tween_property(message, "scale", Vector2.ZERO, duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(message, "modulate:a", 0, duration)
			
			highscore_achieved = true
			
		global.highscore = score
		
		var file = FileAccess.open(global.highscore_path, FileAccess.WRITE)
		file.store_string(str(global.highscore))
		file.close()
		
	start_round()
	
func game_over():
	$timer.stop()
	$labels.visible = false
	
	var veil = $veil
	veil.visible = true
	veil.modulate.a = 0
	
	var tween = create_tween()
	
	tween.tween_property(veil, "modulate:a", 1, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	var button_container = $veil/button_container
	button_container.position.y += 30
	tween.parallel().tween_property(button_container, "position:y",
		button_container.position.y - 30, 0.8)
	
	$veil/score.text = "Score: " + str(score).pad_zeros(3)
