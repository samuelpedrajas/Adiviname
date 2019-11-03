extends Control


func open():
	$SavedGames/ScrollContainer.configure_custom_scrollbar()
	show()

func close():
	hide()

func _on_Button_pressed():
	close()
