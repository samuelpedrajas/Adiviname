extends Control

var GameListItem = preload("res://scenes/GameListItem.tscn")


func _ready():
	ApiRequest.connect("api_request_completed", self, "_api_request_completed")
	ApiRequest.send_request(Const.API_GAME_ENDPOINT)


func _api_request_completed(result, status_code):
	if status_code != 200:
		print("Status code different than 200: " + str(status_code))
	else:
		setup(result)


func setup(results):
	$LoadingIcon.hide()

	for i in range(0, results.size()):
		var game_info = results[i]
		var game_list_item = GameListItem.instance()

		game_list_item.setup(
			game_info["title"], 
			game_info["description"], 
			game_info["expressions"]
		)
		$GameListBg/GameContainer/VBoxContainer.add_child(game_list_item)
