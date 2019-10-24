extends Control


func _ready():
	var value = $Content/VBoxContainer/HSlider.get_value()
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))


func _on_HSlider_value_changed(value):
	$Content/VBoxContainer/NTeams.set_text(str(int(value)))
