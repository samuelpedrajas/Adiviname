extends Control


func _ready():
	randomize()
	get_tree().set_quit_on_go_back(false)
	Main.setup()
	Status.load_status()
	check_for_updates()


func check_for_updates():
	ApiRequest.connect("api_request_completed", self, "handle_update_response")
	ApiRequest.connect("api_request_progress", self, "handle_partial_update_response")
	ApiRequest.connect("api_request_failed", self, "handle_failed_response")
	ApiRequest.send_request(Const.API_GAME_ENDPOINT, {"since_datetime": Status.last_update_timestamp})


func handle_partial_update_response(result, status_code):
	if typeof(result) == TYPE_ARRAY and result.size() > 0:
		var ok = DB.update_database(result)
		if not ok:
			print("There was an error during the DB update")


func handle_failed_response(message, status_code):
	print(message)
	load_games()


func handle_update_response(result, status_code):
	Status.last_update_timestamp = OS.get_unix_time()
	if typeof(result) == TYPE_ARRAY and result.size() > 0:
		var ok = DB.update_database(result)
		if not ok:
			print("There was an error during the DB update")
		else:
			print ("Saving status...")
			Status.save_status()
	load_games()


func load_games():
	ApiRequest.disconnect("api_request_completed", self, "handle_update_response")
	ApiRequest.disconnect("api_request_progress", self, "handle_partial_update_response")
	ApiRequest.disconnect("api_request_failed", self, "handle_failed_response")

	var stored_games = DB.get_games_ordered_by_clicks()
	$"MainMenu/GameList".setup(stored_games)
