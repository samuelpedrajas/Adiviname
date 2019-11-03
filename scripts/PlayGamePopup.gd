extends Control

var new_game = false
var game_list_item


func _ready():
	var saved_games = DB.get_saved_games()
	$Content/SaveGameList.setup(saved_games)


func set_game_info(game_list_item):
	self.game_list_item = game_list_item
	$Content/Title.set_text(game_list_item.game_title)
	$Content/Icon.texture = game_list_item.game_icon_texture
	$Content/Description.set_text(game_list_item.game_description)


func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		$Content/SaveGameList.show()
		_update_btn()
	else:
		$Content/SaveGameList.hide()
		_set_play_game_btn()


func _on_CloseButton_pressed():
	Main.close_popups()


func _on_Button_pressed():
	if self.new_game:
		Main.open_game_configuration_popup(game_list_item)
	else:
		Main.load_game(game_list_item.game_id)


func _set_new_game_btn():
	$Content/Button.set_text("Nueva Partida")
	new_game = true


func _set_play_game_btn():
	$Content/Button.set_text("Jugar")
	new_game = false


func _update_btn():
	var item = $Content/SaveGameList.get_selected()
	if item.save_game_id < 0:
		_set_new_game_btn()
	else:
		_set_play_game_btn()


func _on_SaveGameList_list_updated():
	_update_btn()
