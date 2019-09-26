extends Node

const SQLite = preload("res://lib/gdsqlite.gdns")

var db
var db_name = "res://DB.db"

var game_table = "game"
var expression_table = "expression"


func __ready():
	db = SQLite.new()

	var file = File.new();
	file.open(db_name, file.READ);
	var size = file.get_len();
	db.open_buffered(db_name, file.get_buffer(size), size);

	# Open the database using the db_name found in the path variable
	db.open(db_name)

	# Do a normal query
	var results = db.fetch_array("SELECT * FROM " + game_table + " JOIN " + expression_table + " ON (game_id=expression_game_id);")

	if typeof(results) == TYPE_ARRAY:
		for res in results:
			print(res)
			print("====")
	
	# Close the imported database
	db.close()
