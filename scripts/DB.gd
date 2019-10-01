extends Node

const SQLite = preload("res://lib/gdsqlite.gdns")

var db
var db_source = "res://DB.db"
var db_name = "user://DB.db"

var game_table = "Game"
var expression_table = "Expression"

var recently_added = []
var recently_modified = []


func _ready():
	open_db()


func open_db():
	db = SQLite.new()

	var dir = Directory.new()
	if not dir.file_exists(db_name):
		print("Copying DB...")
		dir.copy(db_source, db_name)
	else:
		print("DB exists")

#	var file = File.new()
#	file.open(db_name, file.READ_WRITE)
#	var size = file.get_len()
#	db.open_buffered(db_name, file.get_buffer(size), size)

	# Open the database using the db_name found in the path variable
	db.open(db_name)


func get_games_ordered_by_clicks():
	return db.fetch_array(
		"SELECT * FROM " + game_table + " ORDER BY game_order;"
	)


func get_game(game_id):
	var result = db.fetch_array(
		"SELECT * FROM " + game_table + " where game_id=" + str(game_id) + ";"
	)
	if result.empty():
		return null
	return result[0]


func get_game_expressions(game_id):
	return db.fetch_array(
		"SELECT expression_text as text FROM " + game_table + " JOIN " + expression_table + " ON (game_id=expression_game_id) where game_id=" + str(game_id) + ";"
	)


func update_game_and_expressions(game):
	print("Updating existing game...")
	var ok = db.query_with_args("""
		UPDATE Game 
		SET game_title=?, game_description=?, game_updated_at=?, game_created_at=?, game_order=? 
		WHERE game_id=?;
	""", [game.title, game.description, game.updated_at, game.created_at, game.order, game.id]
	)
	if not ok:
		return ok

	ok = remove_expressions(game.id)
	if not ok:
		return ok

	return insert_expressions(game.expressions, game.id)


func update_game_order(game):
	print("Updating game order...")
	return db.query_with_args("""
		UPDATE Game 
		SET game_order=? 
		WHERE game_id=?;
	""", [game.order, game.id]
	)


func insert_game(game):
	print("Inserting new game...")
	var ok = db.query_with_args("""
		INSERT INTO Game (game_id, game_title, game_description, game_updated_at, game_created_at, game_order) 
		VALUES (?, ?, ?, ?, ?, ?);
	""", [game.id, game.title, game.description, game.updated_at, game.created_at, game.order]
	)
	if not ok:
		return ok
	return insert_expressions(game.expressions, game.id)


func insert_expressions(expressions, game_id):
	print("Inserting new expressions...")
	var ok
	for expression in expressions:
		ok = db.query_with_args("""
			INSERT INTO Expression (expression_text, expression_game_id) 
			VALUES (?, ?);
		""", [expression, game_id]
		)
		if not ok:
			return ok
	return ok


func remove_expressions(game_id):
	print("Removing expressions of game with id %s..." % game_id)
	return db.query_with_args("""
		DELETE FROM Expression 
		WHERE expression_game_id=?
	""", [game_id])


func update_database(games):
	for i in range(games.size()):
		var game = games[i]
		if game.id == null:
			continue
		game.order = i
		print("Processing game %s..." % game.id)
		var ok
		var stored_game = get_game(game.id)
		if stored_game == null:
			# insert new game
			ok = insert_game(game)
			if ok:
				recently_added.append(game.id)
		elif game.has("expressions"):
			# update game and expressions
			ok = update_game_and_expressions(game)
			if ok:
				recently_modified.append(game.id)
		else:
			# update game order
			ok = update_game_order(game)
		print("Result: ", ok)
		if not ok:
			return false
	return true


func close_db():
	return db.close()
