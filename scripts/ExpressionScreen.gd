extends Control

var countdown = 6
var remaining_time = 60
var current_expression
var pending_expressions = []
var displayed = []
var answers = {}

var blocked = true


func _ready():
	set_next_expression()


func _process(delta):
	if blocked:
		return
	var gyro = Input.get_gyroscope()

	if gyro[1] + gyro[2] < 1:
		if  Const.GyroAnswer.MIN_CORRECT < gyro[0] and gyro[0] < Const.GyroAnswer.MAX_CORRECT:
			$CorrectBg.show()
			answer(true)
		elif Const.GyroAnswer.MIN_INCORRECT < gyro[0] and gyro[0] < Const.GyroAnswer.MAX_INCORRECT:
			$IncorrectBg.show()
			answer(false)


func answer(correct):
	blocked = true
	answers[current_expression] = correct
	$NextExpressionTimer.start()


func set_next_expression():
	if pending_expressions.empty():
		pending_expressions = Global.expressions.duplicate()
		pending_expressions.shuffle()

	current_expression = pending_expressions.pop_front()
	displayed.append(current_expression)

	$GameControls/Expression.set_text(current_expression)


func _on_GameTimer_timeout():
	remaining_time -= 1
	$GameControls/Time.set_text(str(remaining_time))
	if remaining_time < 1:
		Global.load_main_scene()


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
