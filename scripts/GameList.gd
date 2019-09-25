extends Control

var GameListItem = preload("res://scenes/GameListItem.tscn")
var next_request

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	$HTTPRequest.request(Const.API_URL, PoolStringArray([]), false)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if(response_code == 200):
		var json_response = JSON.parse(body.get_string_from_utf8())
		if json_response.error != OK:
			print("Some error while parsing the JSON")
			return
		setup(json_response.result)


func setup(result):
	$LoadingIcon.hide()
	next_request = result["next"]
	var results = result["results"]
	for i in range(0, results.size()):
		var game_info = results[i]
		var game_list_item = GameListItem.instance()

		game_list_item.setup(
			game_info["title"], 
			game_info["description"], 
			game_info["expressions"]
		)
		$GameListBg/GameContainer/VBoxContainer.add_child(game_list_item)
