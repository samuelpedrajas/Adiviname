extends Control

var results_record_scene = preload("res://scenes/ResultsRecord.tscn")
var displayed
var score = 0

var go_back_locked = true

func _ready():
#	setup([
#		{"text": "test 1", "correct": false},
#		{"text": "test 2", "correct": true},
#		{"text": "test 3", "correct": false},
#		{"text": "test 4", "correct": false},
#		{"text": "test 5", "correct": true},
#		{"text": "test 1", "correct": false},
#		{"text": "test 2", "correct": true},
#		{"text": "test 3", "correct": false},
#		{"text": "test 4", "correct": false},
#		{"text": "test 5", "correct": true},
#	])
	if not Main.team_mode:
		var h = $Bottom/CurrentScores.get_size().y
		$Bottom/CurrentScores.hide()
		$Top.set_size(
			$Top.get_size() + 
			Vector2(0, h)
		)

func selection_changed(i, correct):
	if correct != displayed[i]["correct"]:
		if correct:
			score += 1
		else:
			score -= 1
		displayed[i]["correct"] = correct
		$Top/Score.set_text("PUNTUACIÓN: " + str(score))
		$Bottom/CurrentScores.update_current_team(score)


func setup(displayed):
	Main.current_scene = "results"
	self.displayed = displayed
	for i in range(displayed.size()):
		var answer = displayed[i]
		var results_record = results_record_scene.instance()
		results_record.setup(answer["text"], answer["correct"], i)
		results_record.connect("selection_changed", self, "selection_changed")
		if answer["correct"]:
			score += 1
		$Top/List/ScrollContainer/VBoxContainer.add_child(results_record)
	$Top/Score.set_text("PUNTUACIÓN: " + str(score))
	$Bottom/CurrentScores.set_scores(score)


func _on_Continue_pressed():
	close()


func close():
	Main.add_score(score)
	Main.load_main()


func _notification(what):
	if go_back_locked:
		print("go back locked")
		return

	var is_go_back_request = what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST
	if is_go_back_request:
		var popups = Main.root.get_node("MainScreen/Popups")

		if popups.get_children().size() > 0:
			Main.close_popups()
			Main.unlock_goback()
		elif Main.current_scene == "results":
			close()
		elif Main.current_scene == "expression_screen":
			Main.open_confirmation_popup(
				"¿Seguro que quieres volver al menú principal?",
				Main,
				"go_back_main_menu",
				null
			)
