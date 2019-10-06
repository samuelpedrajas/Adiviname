extends Control

onready var grid_container = $GameListBg/GameContainer/VBoxContainer/GridContainer
var GameListItem = preload("res://scenes/GameListItem.tscn")


func setup(results):
	print("Removing existing items")
	for item in grid_container.get_children():
		item.queue_free()
		yield(item, "tree_exited")
	print("Game list is clean")
	print("Adding games to list...")
	for i in range(0, results.size()):
		var game_info = results[i]
		var game_list_item = GameListItem.instance()

		game_list_item.setup(
			game_info["game_id"],
			game_info["game_title"]
		)
		if int(game_info["game_featured"]) > 0:
			game_list_item.set_featured()
		$GameListBg/GameContainer/VBoxContainer/GridContainer.add_child(game_list_item)
