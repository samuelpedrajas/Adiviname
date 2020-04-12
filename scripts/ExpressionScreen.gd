extends Control

const vibration_time = 300
const vibration_threshold = 5

var game_id
var title
var expressions

var countdown = 5
var remaining_time = 10
var current_expression
var pending_expressions = []
var displayed = []

var blocked = true


func _ready():
	$GameControls/Time.set_text(str(remaining_time))
	set_next_expression()


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
		$CorrectBg.show()
	else:
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

	$GameControls/Expression.set_text(current_expression)
	adjust_word_size()


func _on_GameTimer_timeout():
	remaining_time -= 1
	$GameControls/Time.set_text(str(remaining_time))
	if remaining_time < 1:
		end_game()

	if remaining_time <= vibration_threshold:
		Main.vibrate(vibration_time)


func _on_NextExpressionTimer_timeout():
	blocked = false

	$CorrectBg.hide()
	$IncorrectBg.hide()

	set_next_expression()


func _on_CountdownTimer_timeout():
	if countdown > 1:
		countdown -= 1
		$Countdown.set_text(str(countdown))
		Main.vibrate(vibration_time)
	else:
		$Countdown.hide()
		$GameControls.show()
		$CountdownTimer.stop()
		$GameTimer.start()
		if OS.get_name() == "X11":
			$LinuxOnly.show()
		blocked = false


func end_game():
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
	$GameControls.hide()
	$CorrectBg.hide()
	$IncorrectBg.hide()
	OS.set_screen_orientation(1)


func adjust_word_size():
	var expr_label = $GameControls/Expression
	var font = expr_label.get_font("font")
	var words = expr_label.text.split(" ",false)
	var longest_word = ""
	
	for i in words:
		if font.get_string_size(i).x > font.get_string_size(longest_word).x:
			longest_word = i

	var word_length = font.get_string_size(longest_word).x
	expr_label.set_pivot_offset(Vector2(
		expr_label.rect_size.x / 2.0,
		expr_label.rect_size.y / 2.0
	))

	if word_length > OS.get_screen_size().y:
		font.set_size(OS.get_screen_size().y / word_length * 220)
	else:
		font.set_size(240)

	expr_label.set_position(Vector2(
		(OS.get_screen_size().y - expr_label.rect_size.x) / 2.0,
		(OS.get_screen_size().x - expr_label.rect_size.y) / 2.0
	))


func finish():
	queue_free()
	
