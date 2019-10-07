extends Control

var game_id
var featured = false


func set_notification():
	var i = DB.recently_added.find(game_id)
	if game_id in DB.recently_added:
		DB.recently_added.erase(i)
		$Button/NotificationRect/Text.set_text("NEW!")
		$Button/NotificationRect.show()
		return

	i = DB.recently_modified.find(game_id)
	if game_id in DB.recently_modified:
		DB.recently_modified.erase(i)
		$Button/NotificationRect/Text.set_text("UPDATED!")
		$Button/NotificationRect.show()
		return


func set_featured():
	self.featured = true
	$Button.set_self_modulate(Color(0, 0, 0, 1.0))


func set_icon(game_icon_path):
    var img = Image.new()
    var itex = ImageTexture.new()
    img.load(game_icon_path)
    itex.create_from_image(img)
    $Button/TextureRect.texture = itex


func setup(game_id, game_title, game_icon_path):
	self.game_id = game_id

	if game_icon_path != null:
		set_icon(game_icon_path)

	set_notification()
	$Button/Title.set_text(game_title)


func _on_Button_pressed():
	if not get_parent().get_parent().get_parent().swiping:
		Main.load_game(game_id)
		$Button/NotificationRect.hide()
