extends Control

var new_game = false
var game_list_item
var saved_games
var original_w_size
var savegames_opened
var is_ready = false

func _ready():
	is_ready = false
	saved_games = DB.get_saved_games_and_results()
	$Content/SaveGameList.setup(saved_games)
	$Content/CheckBox.set_pressed(Main.team_mode or savegames_opened)
	original_w_size = $Content.get_size()
	if Main.team_mode or savegames_opened:
		_set_extended_size()
	is_ready = true
	call_deferred("update_game_mode", Main.team_mode or savegames_opened)

func set_game_info(game_list_item, savegames_opened):
	self.savegames_opened = savegames_opened
	self.game_list_item = game_list_item
	$Content/Title.set_text(game_list_item.game_title)
	if game_list_item.game_title.length() > 20:
		$Content/Title.set_scale(
			Vector2(0.8, 0.8)
		)
	$Content/Icon.texture = game_list_item.game_icon_texture
	$Content/Description.set_text(game_list_item.game_description)
	$Content/Examples.set_text(
		"Ej: " + game_list_item.game_examples
	)

func _on_CheckBox_toggled(button_pressed):
	if not is_ready:
		return
	Main.play_sound("Click")
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
	Main.play_sound("Click")
	Main.close_popups()

func _on_Button_pressed():
	if self.new_game:
		Main.play_sound("Click")
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
	$Content/NGButton.show()
	$Content/PlayButton.hide()

func _set_play_game_btn():
	# TODO
	#$Content/Button.set_text("Jugar")
	new_game = false
	$Content/NGButton.hide()
	$Content/PlayButton.show()

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


func _on_PlayGamePopup_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Main.close_popups()
