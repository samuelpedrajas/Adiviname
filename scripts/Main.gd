extends Node

var root

var current_scene = "main"

var expression_screen_scene = preload("res://scenes/ExpressionScreen.tscn")

func setup():
	root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )


func load_game(game_id):
	current_scene = "expression_screen"

	var game = DB.get_game(game_id)
	var expression_screen = expression_screen_scene.instance()
	expression_screen.game_id = game_id
	expression_screen.title = game.game_title
	expression_screen.description = game.game_description
	expression_screen.expressions = DB.get_game_expressions(game_id)

	var game_screen = root.get_node("MainScreen/GameScreen")
	game_screen.add_child(expression_screen)

	var main_menu = root.get_node("MainScreen/MainMenu")
	main_menu.hide()

	OS.set_screen_orientation(0)


func load_main():
	current_scene = "main"

	var main_menu = root.get_node("MainScreen/MainMenu")
	main_menu.show()

	var game_screen = root.get_node("MainScreen/GameScreen")
	var screens = game_screen.get_children()
	for screen in screens:
		screen.finish()

	OS.set_screen_orientation(1)


func quit_game():
	Status.save_status()
	DB.close_db()
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
