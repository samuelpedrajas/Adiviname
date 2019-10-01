extends Control

var GameListItem = preload("res://scenes/GameListItem.tscn")


func setup(results):
	$LoadingIcon.hide()

	for i in range(0, results.size()):
		var game_info = results[i]
		var game_list_item = GameListItem.instance()

		game_list_item.setup(
			game_info["game_id"],
			game_info["game_title"], 
			game_info["game_description"]
		)
		$GameListBg/GameContainer/VBoxContainer.add_child(game_list_item)
