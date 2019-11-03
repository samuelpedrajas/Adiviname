extends Control

export(int) var save_game_id = -1
export(bool) var selected = false

signal item_selected

func _ready():
	if self.selected:
		set_selected()


func setup(save_game_id, name):
	self.save_game_id = save_game_id
	$Button.set_text(name)


func set_selected():
	$ColorRect.show()
	$Button.set_pressed(true)


func unset_selected():
	$ColorRect.hide()
	$Button.set_pressed(false)


func _on_Button_pressed():
	emit_signal("item_selected", self)
