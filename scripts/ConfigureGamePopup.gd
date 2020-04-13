extends Control

var game_id


func _ready():
	var value = $Content/VBoxContainer/HSlider.get_value()
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))


func setup(game_list_item, game_id):
	$Content/VBoxContainer/Game.set_text(
		game_list_item.game_title
	)
	self.game_id = game_id

	var current_time = OS.get_datetime()
	# 23-10-2019 14:55:00
	$Content/VBoxContainer/TextEdit.set_text(
		str(current_time.day).pad_zeros(2) + "-" + 
		str(current_time.month).pad_zeros(2) + "-" +
		str(current_time.year) + " " + 
		str(current_time.hour).pad_zeros(2) + ":" +
		str(current_time.minute).pad_zeros(2) + ":" + 
		str(current_time.second).pad_zeros(2)
	)


func _on_HSlider_value_changed(value):
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))


func _on_CloseButton_pressed():
	Main.close_popups()


func _on_PlayButton_pressed():
	var game_name = $Content/VBoxContainer/TextEdit.get_text()
	var n_teams = $Content/VBoxContainer/HSlider.get_value()
	var saved_game = DB.insert_saved_game(n_teams, game_name)
	Main.load_saved_game(saved_game)
	Main.load_game(game_id)

# copied code

export(int) var LIMIT = 30
var current_text = ''
var cursor_line = 0
var cursor_column = 0

func _on_TextEdit_text_changed():
	var text_edit = $Content/VBoxContainer/TextEdit
	var new_text : String = text_edit.text
	if new_text.length() > LIMIT:
		text_edit.text = current_text
		# when replacing the text, the cursor will get moved to the beginning of the
		# text, so move it back to where it was
		text_edit.cursor_set_line(cursor_line)
		text_edit.cursor_set_column(cursor_column)

	current_text = text_edit.text
	# save current position of cursor for when we have reached the limit
	cursor_line = text_edit.cursor_get_line()
	cursor_column = text_edit.cursor_get_column()

	if current_text == "":
		$Content/PlayButton.set_disabled(true)
	else:
		$Content/PlayButton.set_disabled(false)
