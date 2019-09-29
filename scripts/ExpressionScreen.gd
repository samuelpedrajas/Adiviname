extends Control

var title
var description
var expressions

var countdown = 5
var remaining_time = 60
var current_expression
var pending_expressions = []
var displayed = []

var blocked = true


func _ready():
	set_next_expression()


func _process(delta):
	if blocked:
		return
	var gyro = Input.get_gyroscope()

	if abs(gyro[1] + gyro[2]) < Const.GyroAnswer.YZ_THRESHOLD:
		if  Const.GyroAnswer.MIN_CORRECT < gyro[0] and gyro[0] < Const.GyroAnswer.MAX_CORRECT:
			$CorrectBg.show()
			answer(true)
		elif Const.GyroAnswer.MIN_INCORRECT < gyro[0] and gyro[0] < Const.GyroAnswer.MAX_INCORRECT:
			$IncorrectBg.show()
			answer(false)


func answer(correct):
	blocked = true

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

	current_expression = pending_expressions.pop_front()

	# this can happen if pending_expressions was empty and we had bad luck when shuffling
	if displayed.size() > 0 and displayed.back()["text"] == current_expression:
		pending_expressions.append(current_expression)
		current_expression = pending_expressions.pop_front()

	displayed.append({ "text": current_expression, "correct": false })

	$GameControls/Expression.set_text(current_expression)


func _on_GameTimer_timeout():
	remaining_time -= 1
	$GameControls/Time.set_text(str(remaining_time))
	if remaining_time < 1:
		Main.load_main()


func _on_NextExpressionTimer_timeout():
	blocked = false

	$CorrectBg.hide()
	$IncorrectBg.hide()

	set_next_expression()


func _on_CountdownTimer_timeout():
	if countdown > 1:
		countdown -= 1
		$Countdown.set_text(str(countdown))
	else:
		$Countdown.hide()
		$GameControls.show()
		$CountdownTimer.stop()
		$GameTimer.start()
		blocked = false


func finish():
	$GameTimer.stop()
	$NextExpressionTimer.stop()
	queue_free()
