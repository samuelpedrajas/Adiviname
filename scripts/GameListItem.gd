extends Control

var game_id
var game_title
var game_description
var game_examples
var game_icon_texture
var game_base_icon_texture
var featured = false


func set_notification():
	var i = DB.recently_added.find(game_id)
	if game_id in DB.recently_added:
		DB.recently_added.erase(i)
		$Button/NotificationRect/New.show()
		return

	i = DB.recently_modified.find(game_id)
	if game_id in DB.recently_modified:
		DB.recently_modified.erase(i)
		$Button/NotificationRect/Updated.show()
		return


func set_featured():
	self.featured = true
	#$Button.set_self_modulate(Color(1, 1, 0.1, 1.0))


func get_icon_texture(game_icon_path):
	var img = Image.new()
	var itex = ImageTexture.new()
	img.load(game_icon_path)
	itex.create_from_image(img)
	return itex


func setup(game_id, game_title, game_description, game_examples, game_icon_path, game_base_icon_path):
	self.game_id = game_id
	self.game_title = game_title
	self.game_description = game_description
	self.game_examples = game_examples

	if game_icon_path != null:
		self.game_icon_texture = get_icon_texture(game_icon_path)
		$Button/TextureRect.texture = game_icon_texture

	if game_base_icon_path != null:
		self.game_base_icon_texture = get_icon_texture(game_base_icon_path)
		$Button.set_normal_texture(game_base_icon_texture)

	set_notification()
	$Button/Title.set_text(game_title)


func _on_Button_pressed():
	if not get_parent().get_parent().swiping:
		Main.open_play_game_popup(self, false)
		$Button/NotificationRect.hide()
