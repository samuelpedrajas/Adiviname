extends Control

var record_index

signal selection_changed

func setup(text, checked, record_index):
	self.record_index = record_index
	$CheckBox.set_text(text)
	$CheckBox.set_pressed(checked)


func _on_CheckBox_toggled(button_pressed):
	if not get_parent().get_parent().swiping:
		emit_signal("selection_changed", record_index, button_pressed)
	else:
		$CheckBox.set_pressed(not button_pressed)
