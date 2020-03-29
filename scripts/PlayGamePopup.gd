extends Control

var new_game = false
var game_list_item
var saved_games
var original_w_size

func _ready():
	saved_games = DB.get_saved_games_and_results()
	$Content/SaveGameList.setup(saved_games)
	$Content/CheckBox.set_pressed(Main.team_mode)
	original_w_size = $Content.get_size()
	if Main.team_mode:
		_set_extended_size()
	call_deferred("update_game_mode", Main.team_mode)

func set_game_info(game_list_item):
	self.game_list_item = game_list_item
	$Content/Title.set_text(game_list_item.game_title)
	$Content/Icon.texture = game_list_item.game_icon_texture
	$Content/Description.set_text(game_list_item.game_description)

func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		_set_extended_size()
	else:
		_set_original_size()
	update_game_mode(button_pressed)

func update_game_mode(game_mode):
	if game_mode:
		var selected_item = $Content/SaveGameList.selected_item
		if selected_item.save_game_id != -1:
			Main.load_saved_game(selected_item.save_game)
			$Content/Turno.show()
		$Content/SaveGameList.show()
		_update_btn()
	else:
		Main.solo_mode()
		$Content/SaveGameList.hide()
		$Content/Turno.hide()
		_set_play_game_btn()

func _on_CloseButton_pressed():
	Main.close_popups()

func _on_Button_pressed():
	if self.new_game:
		Main.open_game_configuration_popup(game_list_item, game_list_item.game_id)
	else:
		Main.load_game(game_list_item.game_id)

func _set_original_size():
	$Content.set_size(original_w_size)
	$Content/NinePatchRect.set_size(original_w_size)

func _set_extended_size():
	var y_offset = $Content/SaveGameList.get_size().y
	y_offset += $Content/Turno.rect_size.y

	$Content.set_size(
		original_w_size + Vector2(0, y_offset)
	)
	$Content/NinePatchRect.set_size(
		original_w_size + Vector2(0, y_offset)
	)

func _set_new_game_btn():
	# TODO
	#$Content/Button.set_text("Nueva Partida")
	new_game = true

func _set_play_game_btn():
	# TODO
	#$Content/Button.set_text("Jugar")
	new_game = false

func _update_btn():
	var item = $Content/SaveGameList.get_selected()
	if item.save_game_id < 0:
		_set_new_game_btn()
	else:
		_set_play_game_btn()

func _on_SaveGameList_list_updated(item):
	if item.save_game_id != -1:
		Main.load_saved_game(item.save_game)
		$Content/Turno.set_text(
			"Turno para el Equipo " + str(
				Main.saved_game.saved_game_next_team + 1
			)
		)
		$Content/Turno.show()
	else:
		$Content/Turno.hide()
		Main.solo_mode()
	_update_btn()
