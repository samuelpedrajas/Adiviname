extends Control

export(int) var save_game_id = -1
export(bool) var selected = false

var save_game

signal item_selected

func _ready():
	if self.selected:
		set_selected()


func setup(save_game):
	self.save_game_id = save_game.saved_game_id
	self.save_game = save_game
	$Button.set_text(save_game.saved_game_name)


func set_selected():
	$ColorRect.show()
	$Button.set_pressed(true)


func unset_selected():
	$ColorRect.hide()
	$Button.set_pressed(false)


func _on_Button_pressed():
	emit_signal("item_selected", self)
