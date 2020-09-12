extends Control

onready var filters = $MainMenu/Filters


func _ready():
	randomize()
	get_tree().set_quit_on_go_back(false)
	Main.setup()
	Status.load_status()
	check_for_updates()


func check_for_updates():
	filters.connect("filters_changed", self, "load_games")
	ApiRequest.connect("api_request_completed", self, "handle_update_response")
	ApiRequest.connect("api_request_progress", self, "handle_partial_update_response")
	ApiRequest.connect("api_request_failed", self, "handle_failed_response")
	ApiRequest.send_request(Const.API_GAME_ENDPOINT, {"since_datetime": Status.last_update_timestamp})


func handle_partial_update_response(result, status_code, next):
	if typeof(result) == TYPE_ARRAY and result.size() > 0:
		var state = DB.update_database(result)
		var ok
		if state is GDScriptFunctionState:
			ok = yield(DB, "database_updated")
		else:
			ok = state
		if not ok:
			print("There was an error during the DB update")

	$LoadingScreen.grow_bar(
		(ApiRequest.request_count / ApiRequest.total_requests) * 100
	)
	ApiRequest.request(next)


func handle_failed_response(message, status_code):
	print(message)
	_finish_loading()
	load_games()


func handle_update_response(result, status_code):
	Status.last_update_timestamp = ApiRequest.last_request_timestamp
	if typeof(result) == TYPE_ARRAY and result.size() > 0:
		var state = DB.update_database(result)
		var ok
		if state is GDScriptFunctionState:
			ok = yield(DB, "database_updated")
		else:
			ok = state
		if not ok:
			print("There was an error during the DB update")
		else:
			print ("Saving status...")
			Status.save_status()
	_finish_loading()
	load_games()


func _finish_loading():
	ApiRequest.disconnect("api_request_completed", self, "handle_update_response")
	ApiRequest.disconnect("api_request_progress", self, "handle_partial_update_response")
	ApiRequest.disconnect("api_request_failed", self, "handle_failed_response")
	filters.set_home_filter()
	$LoadingScreen.hide()
	get_viewport().set_disable_input(false)
	Main.go_back_locked = false
	# $Popups/PlayGame.popup_centered()


func load_games():
	var stored_games = filters.get_games()  # set to home by default
	$"MainMenu/GameList".setup(stored_games)


func _on_Results_pressed():
	$ResultsScreen.open()


func _on_Help_pressed():
	$Tutorial.open()
