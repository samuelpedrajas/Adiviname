extends Control


func _ready():
	var value = $Content/VBoxContainer/HSlider.get_value()
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))


func setup(game_list_item):
	$Content/VBoxContainer/Game.set_text(
		game_list_item.game_title
	)


func _on_HSlider_value_changed(value):
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))


func _on_CloseButton_pressed():
	Main.close_popups()
