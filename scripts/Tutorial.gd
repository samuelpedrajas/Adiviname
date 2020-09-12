extends Control


func open():
	Main.current_scene = "tutorial"
	$"../MainMenu".hide()
	show()


func close():
	$"../MainMenu".show()
	Main.current_scene = "main"
	hide()


func _on_BackButton_pressed():
	close()
