extends Control

const vibration_time = 300
const vibration_threshold = 5

var game_id
var title
var expressions

var max_countdown = 5
var countdown = max_countdown
var remaining_time = 90
var current_expression
var pending_expressions = []
var displayed = []

var expr_label
var font
var font_size

var blocked = true


func _ready():
	call_deferred("start")


func start():
	yield(get_tree().create_timer(2.0), "timeout")
	$CountdownTimer.start()
	$Countdown.set_text(str(max_countdown))
	Main.vibrate(vibration_time)
	Main.play_sound("Countdown")
	prepare_game()


func _process(delta):
	if blocked:
		return
	var gyro = Input.get_gyroscope()

	if abs(gyro[1]) + abs(gyro[2]) < Const.GyroAnswer.YZ_THRESHOLD:
		if  Const.GyroAnswer.MIN_CORRECT < gyro[0] and gyro[0] < Const.GyroAnswer.MAX_CORRECT:
			answer(true)
		elif Const.GyroAnswer.MIN_INCORRECT < gyro[0] and gyro[0] < Const.GyroAnswer.MAX_INCORRECT:
			answer(false)


func answer(correct):
	blocked = true
	if correct:
		Main.play_sound("Ding")
		$CorrectBg.show()
	else:
		Main.play_sound("Error")
		$IncorrectBg.show()

	if displayed.size() < 1:
		print("There was some error in the answer function")
		return

	var last_displayed = displayed.back()
	last_displayed["correct"] = correct

	$NextExpressionTimer.start()


func set_next_expression():
	if pending_expressions.empty():
		pending_expressions = expressions.duplicate()
		pending_expressions.shuffle()

	var current_expression_dict = pending_expressions.pop_front()
	current_expression = current_expression_dict["text"]

	# this can happen if pending_expressions was empty and we had bad luck when shuffling
	if displayed.size() > 0 and displayed.back()["text"] == current_expression:
		pending_expressions.append(current_expression_dict)
		current_expression = pending_expressions.pop_front()["text"]

	displayed.append({ "text": current_expression, "correct": false })

	font.set_size(font_size)
	set_expression(current_expression)


func _on_GameTimer_timeout():
	remaining_time -= 1
	$GameControls/Time.set_text(str(remaining_time))
	if remaining_time < 1:
		Main.play_sound("DingDing")
		end_game()
	elif remaining_time <= vibration_threshold:
		Main.play_sound("Countdown")
		Main.vibrate(vibration_time)


func _on_NextExpressionTimer_timeout():
	blocked = false

	$CorrectBg.hide()
	$IncorrectBg.hide()

	set_next_expression()

func prepare_game():
	$GameControls/Time.set_text(str(remaining_time))
	expr_label = $GameControls/Expression
	font = expr_label.get_font("font")
	font_size = 1.0 * font.get_size()
	set_next_expression()
	Main.unlock_goback()
	$Results.go_back_locked = false

func _on_CountdownTimer_timeout():
	if countdown > 1:
		countdown -= 1
		$Countdown.set_text(str(countdown))
		Main.play_sound("Countdown")
		Main.vibrate(vibration_time)
	else:
		$Countdown.hide()
		adjust_font_size()
		$CountdownTimer.stop()
		$GameTimer.start()
		if OS.get_name() == "X11":
			$LinuxOnly.show()
		blocked = false


func end_game():
	font.set_size(font_size)
	ApiRequest.send_request(
		Const.API_GAME_CLICK_ENDPOINT + str(game_id),
		{},
		PoolStringArray([]),
		HTTPClient.METHOD_POST
	)
	$GameTimer.stop()
	$NextExpressionTimer.stop()
	$Results.setup(displayed)
	$Results.show()
	$LinuxOnly.hide()
	$CorrectBg.hide()
	$IncorrectBg.hide()
	OS.set_screen_orientation(1)


func set_expression(current_expression):
	font.set_size(font_size)
	expr_label.set_text(current_expression)
	adjust_font_size()


func adjust_font_size():
	var words = expr_label.text.split(" ", false)
	var longest_word = ""
	for i in words:
		if font.get_string_size(i).x > font.get_string_size(longest_word).x:
			longest_word = i
	var word_length = font.get_string_size(longest_word).x

	var expression_size = get_parent().rect_size
	if word_length > expression_size.x:
		font.set_size(expression_size.x / word_length * font_size * 0.90)

	expr_label.rect_size = expression_size
	expr_label.set_position(Vector2(0, 0))


func finish():
	queue_free()
	
