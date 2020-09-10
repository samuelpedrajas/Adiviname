extends Control

onready var grid_container = $GameContainer/GridContainer
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
			game_info["game_examples"],
			game_info["game_icon_path"],
			game_info["game_icon_base_path"]
		)

		var grid_container = $GameContainer/GridContainer
		grid_container.add_child(game_list_item)
		if int(game_info["game_featured"]) > 0:
			game_list_item.set_featured()
			grid_container.move_child(game_list_item, 0)

	call_deferred("resize")

func resize():
	$GameContainer.set_custom_minimum_size(
		Vector2(
			grid_container.get_size().x,
			$GameContainer.get_custom_minimum_size().y
		)
	)
	$GameContainer.set_position(
		Vector2(
			get_parent().get_size().x / 2.0 - grid_container.get_size().x / 2.0,
			0
		)
	)
