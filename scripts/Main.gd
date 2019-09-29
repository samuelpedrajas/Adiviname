extends Control

var current_scene = "main"

var expression_screen_scene = preload("res://scenes/ExpressionScreen.tscn")


func _ready():
	randomize()
	get_tree().set_quit_on_go_back(false)


func load_game(title, description, expressions):
	current_scene = "expression_screen"

	var expression_screen = expression_screen_scene.instance()
	expression_screen.title = title
	expression_screen.description = description
	expression_screen.expressions = expressions

	var game_screen = get_tree().get_root().get_node("Main/GameScreen")
	game_screen.add_child(expression_screen)

	var main_menu = get_tree().get_root().get_node("Main/MainMenu")
	main_menu.hide()

	OS.set_screen_orientation(0)


func load_main():
	current_scene = "main"

	var main_menu = get_tree().get_root().get_node("Main/MainMenu")
	main_menu.show()

	var game_screen = get_tree().get_root().get_node("Main/GameScreen")
	var screens = game_screen.get_children()
	for screen in screens:
		screen.finish()

	OS.set_screen_orientation(1)


func quit_game():
	get_tree().quit()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if current_scene != "main":
			load_main()
		else:
			quit_game()
	elif what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if current_scene != "main":
			load_main()
		else:
			quit_game()
