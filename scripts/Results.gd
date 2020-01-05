extends Control

var results_record_scene = preload("res://scenes/ResultsRecord.tscn")
var displayed
var score = 0


func _ready():
#	setup([
#		{"text": "test 1", "correct": false},
#		{"text": "test 2", "correct": true},
#		{"text": "test 3", "correct": false},
#		{"text": "test 4", "correct": false},
#		{"text": "test 5", "correct": true},
#	])
	pass

func selection_changed(i, correct):
	if correct != displayed[i]["correct"]:
		if correct:
			score += 1
		else:
			score -= 1
		displayed[i]["correct"] = correct
		$Top/Score.set_text(str(score))


func setup(displayed):
	self.displayed = displayed
	for i in range(displayed.size()):
		var answer = displayed[i]
		var results_record = results_record_scene.instance()
		results_record.setup(answer["text"], answer["correct"], i)
		results_record.connect("selection_changed", self, "selection_changed")
		if answer["correct"]:
			score += 1
		$ScrollContainer/VBoxContainer.add_child(results_record)
	$Top/Score.set_text(str(score))


func _on_Continue_pressed():
	Main.add_score(score)
	Main.load_main()
