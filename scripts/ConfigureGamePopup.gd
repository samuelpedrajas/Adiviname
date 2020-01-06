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
