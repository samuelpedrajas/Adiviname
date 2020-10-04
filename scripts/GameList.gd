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
	$GameContainer.set_v_scroll(0)
	$GameContainer.remove_child(grid_container)
	grid_container = GridContainer.new()
	grid_container.set_columns(2)

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
	$GameContainer.add_child(grid_container)
	call_deferred("resize")

func resize():
	var w = grid_container.get_size().x
	var h = get_size().y
	if grid_container.get_size().y < h:
		$GameContainer.set_enable_v_scroll(false)
	else:
		$GameContainer.set_enable_v_scroll(true)
	print("Parent: ", get_size())
	print("W: ", w, " H: ", h)
	$GameContainer.set_size(
		Vector2(w, h)
	)
	$GameContainer.set_position(
		Vector2(
			get_parent().get_size().x / 2.0 - $GameContainer.get_size().x / 2.0,
			0
		)
	)
