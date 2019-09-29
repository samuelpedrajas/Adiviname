extends Node

var last_update_timestamp = 0


func load_status():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return

	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if "last_update_timestamp" in current_line.keys():
			last_update_timestamp = current_line["last_update_timestamp"]
	save_game.close()


func save_status():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json({ "last_update_timestamp": last_update_timestamp }))
	save_game.close()
