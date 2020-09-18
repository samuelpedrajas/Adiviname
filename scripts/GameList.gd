extends Control

onready var grid_container = $GameContainer/GridContainer
var GameListItem = preload("res://scenes/GameListItem.tscn")

var game_cache = {}


func setup(results, featured):
	print("Removing existing items")
	for item in grid_container.get_children():
		grid_container.remove_child(item)

	#print("TERCERO!!!!!  ", OS.get_datetime_from_unix_time(OS.get_unix_time()).second)
	print("Game list is clean")

	print("Adding games to list...")
	for i in range(0, results.size()):
		var game_info = results[i]
		var game_list_item
		if game_cache.has(game_info["game_id"]):
			game_list_item = game_cache[game_info["game_id"]]
		else:
			game_list_item = GameListItem.instance()
			game_list_item.setup(
				game_info["game_id"],
				game_info["game_title"],
				game_info["game_description"],
				game_info["game_examples"],
				game_info["game_icon_path"],
				game_info["game_icon_base_path"]
			)
			game_cache[game_info["game_id"]] = game_list_item

		grid_container.add_child(game_list_item)
		if int(game_info["game_featured"]) > 0:
			game_list_item.set_featured()
			if featured:
				grid_container.move_child(game_list_item, 0)
	#print("CUARTO!!!!!!  ", OS.get_datetime_from_unix_time(OS.get_unix_time()).second)
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
