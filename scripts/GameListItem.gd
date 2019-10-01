extends Control

var game_id


func set_notification():
	var i = DB.recently_added.find(game_id)
	if i >=0:
		DB.recently_added.remove(i)
		$Button/NotificationRect/Text.set_text("NEW!")
		$Button/NotificationRect.show()
		return

	i = DB.recently_modified.find(game_id)
	if game_id in DB.recently_modified:
		DB.recently_modified.remove(i)
		$Button/NotificationRect/Text.set_text("UPDATED!")
		$Button/NotificationRect.show()
		return


func setup(game_id, game_title, game_description):
	self.game_id = game_id

	set_notification()
	$Button/Title.set_text(game_title)
	$Button/Description.set_text(game_description)


func _on_Button_pressed():
	if not get_parent().get_parent().swiping:
		Main.load_game(game_id)
		$Button/NotificationRect.hide()
