extends Control

var game_id
var game_list_item


func _ready():
	var value = $Content/VBoxContainer/HSlider.get_value()
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))


func setup(game_list_item, game_id):
	self.game_list_item = game_list_item
	$Content/VBoxContainer/Game.set_text(
		game_list_item.game_title
	)
	self.game_id = game_id

	var current_time = OS.get_datetime()
	# 23-10-2019 14:55:00
	$Content/VBoxContainer/LineEdit.set_text(
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
	Main.open_play_game_popup(game_list_item, true)


func _on_PlayButton_pressed():
	var game_name = $Content/VBoxContainer/LineEdit.get_text()
	var n_teams = $Content/VBoxContainer/HSlider.get_value()
	var saved_game = DB.insert_saved_game(n_teams, game_name)
	Main.load_saved_game(saved_game)
	Main.load_game(game_id)


func _on_ConfigureGamePopup_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Main.close_popups()


func _on_LineEdit_text_changed(new_text):
	if new_text == "":
		$Content/PlayButton.set_disabled(true)
	else:
		$Content/PlayButton.set_disabled(false)
