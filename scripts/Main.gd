extends Node

var root
var vibration

var current_scene = "main"

var expression_screen_scene = preload("res://scenes/ExpressionScreen.tscn")
var play_game_popup_scene = preload("res://scenes/PlayGamePopup.tscn")
var configure_game_popup_scene = preload("res://scenes/ConfigureGamePopup.tscn")

var team_mode = false
var saved_game

var go_back_locked = false

func _ready():
	if not Const.DEBUG:
		get_viewport().set_disable_input(true)

	if Engine.has_singleton("Vibration"):
		vibration = Engine.get_singleton("Vibration")

func add_score(score):
	if not team_mode:
		return
	print("Updating score of team ", saved_game.saved_game_next_team)
	DB.add_score(
		saved_game.saved_game_id,
		saved_game.saved_game_next_team,
		score
	)
	saved_game.results[saved_game.saved_game_next_team].saved_game_team_score += score
	saved_game.saved_game_next_team = (
		(saved_game.saved_game_next_team + 1) % saved_game.results.size()
	)
	DB.next_team(
		saved_game.saved_game_id,
		saved_game.saved_game_next_team
	)
	print("Next player: ", saved_game.saved_game_next_team)

func load_saved_game(saved_game):
	print("Enabling team mode")
	self.saved_game = saved_game
	self.team_mode = true

func solo_mode():
	print("Enabling solo mode")
	self.team_mode = false

func setup():
	root = get_tree().get_root()

func vibrate(duration):
	if vibration:
		vibration.vibrate(duration)

func load_game(game_id):
	current_scene = "expression_screen"
	close_popups()

	var game = DB.get_game(game_id)
	var expression_screen = expression_screen_scene.instance()
	expression_screen.game_id = game_id
	expression_screen.title = game.game_title
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


func open_play_game_popup(game_list_item, savegames_opened=false):
	var play_game_popup = play_game_popup_scene.instance()
	play_game_popup.set_game_info(game_list_item, savegames_opened)
	_open_popup(play_game_popup)


func open_game_configuration_popup(game_list_item, game_id):
	var ogc_popup = configure_game_popup_scene.instance()
	ogc_popup.setup(game_list_item, game_id)
	_open_popup(ogc_popup)


func _open_popup(popup):
	close_popups()
	root.get_tree().set_pause(true)
	var popups = root.get_node("MainScreen/Popups")
	popups.add_child(popup)
	popups.show()


func close_popups():
	var popups = root.get_node("MainScreen/Popups")
	for popup in popups.get_children():
		popup.queue_free()
	popups.hide()
	root.get_tree().set_pause(false)


func quit_game():
	Status.save_status()
	DB.close_db()
	get_tree().quit()


func _notification(what):
	print("button pressed: ", what)
	print("current_scene: ", current_scene)

	if go_back_locked:
		print("go back locked")
		return

	var is_go_back_request = what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST
	if is_go_back_request:
		go_back_locked = true
		if current_scene != "main":
			load_main()
			yield(get_tree().create_timer(1), "timeout")
			go_back_locked = false
		else:
			quit_game()
