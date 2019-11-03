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
			game_info["game_title"],
			game_info["game_description"],
			game_info["game_icon_path"]
		)

		var grid_container = $GameListBg/GameContainer/VBoxContainer/GridContainer
		grid_container.add_child(game_list_item)
		if int(game_info["game_featured"]) > 0:
			game_list_item.set_featured()
			grid_container.move_child(game_list_item, 0)
