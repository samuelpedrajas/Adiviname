extends HTTPRequest

const SQLite = preload("res://lib/gdsqlite.gdns")

var db
var db_source = "res://DB.db"
var db_name = "user://DB.db"

var recently_added = []
var recently_modified = []

signal database_updated


func _ready():
	if Const.DEBUG:
		return

	var dir = Directory.new()
	if not dir.dir_exists(Const.ICON_PATH):
		dir.make_dir(Const.ICON_PATH)

	if not dir.dir_exists(Const.ICON_BASE_PATH):
		dir.make_dir(Const.ICON_BASE_PATH)

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
		"SELECT * FROM Game ORDER BY game_order desc;"
	)


func get_games_ordered_by_creation_date():
	return db.fetch_array(
		"""SELECT * FROM Game 
		ORDER BY game_created_at desc, 
			game_updated_at desc, 
			game_order desc;"""
	)


func get_normal_games_ordered_by_clicks():
	return db.fetch_array(
		"""SELECT * 
		FROM Game 
		WHERE game_type='normal' 
		ORDER BY game_order desc;"""
	)


func get_gesture_games_ordered_by_clicks():
	return db.fetch_array(
		"""SELECT * 
		FROM Game 
		WHERE game_type='gestos' 
		ORDER BY game_order desc;"""
	)


func get_game(game_id):
	var result = db.fetch_array(
		"SELECT * FROM Game where game_id=" + str(game_id) + ";"
	)
	if result.empty():
		return null
	return result[0]


func get_game_expressions(game_id):
	return db.fetch_array(
		"SELECT expression_text as text FROM Game JOIN Expression ON (game_id=expression_game_id) where game_id=" + str(game_id) + ";"
	)


func update_game(game):
	print("Updating existing game...")
	var values = [game.title, game.featured, game.game_type, game.updated_at, game.created_at, game.order, game.description, game.id]
	for value in values:
		if value == null:
			return false
	var ok = db.query_with_args("""
		UPDATE Game 
		SET game_title=?, game_featured=?, game_type=?, game_updated_at=?, game_created_at=?, game_order=?, game_description=? 
		WHERE game_id=?;
	""", values
	)
	return ok


func update_game_expressions(game_id, game_expressions):
	print("Updating expressions of game...")
	var ok = remove_expressions(game_id)
	if not ok:
		return ok

	return insert_expressions(game_expressions, game_id)


func update_game_order(game):
	print("Updating game order...")
	return db.query_with_args("""
		UPDATE Game 
		SET game_order=? 
		WHERE game_id=?;
	""", [game.order, game.id]
	)


func update_game_image(game, body):
	var image_path = save_image(Const.ICON_PATH + str(game.id) + ".png", body)
	print("Updating icon path...")
	return db.query_with_args("""
		UPDATE Game 
		SET game_icon_path=? 
		WHERE game_id=?;
	""", [image_path, game.id]
	)


func file_exists(filepath):
	var f = File.new()
	return f.file_exists(filepath)


func update_game_image_base(game, body):
	var image_path = Const.ICON_BASE_PATH + game.icon_base.name + ".png"
	if body != null:
		image_path = save_image(image_path, body)

	print("Updating base icon path...")
	return db.query_with_args("""
		UPDATE Game 
		SET game_icon_base_path=? 
		WHERE game_id=?;
	""", [image_path, game.id]
	)

func insert_game(game):
	print("Inserting new game...")
	var values = [game.id, game.title, game.featured, game.game_type, game.updated_at, game.created_at, game.order, game.description]
	for value in values:
		if value == null:
			return false
	var ok = db.query_with_args("""
		INSERT INTO Game (game_id, game_title, game_featured, game_type, game_updated_at, game_created_at, game_order, game_description) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?);
	""", values
	)
	if not ok:
		return false
	return insert_expressions(game.expressions, game.id)


func insert_expressions(expressions, game_id):
	if expressions.empty():
		print("No expressions to insert")
		return true
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
	var ok = false
	for i in range(games.size()):
		var game = games[i]
		if game.id == null:
			continue
		elif game.has('featured'):
			game.featured = int(game.featured)
		game.order = game.clicks
		print("Processing game %s..." % game.id)
		var stored_game = get_game(game.id)
		if stored_game == null and game.has('title'):
			# insert new game
			ok = insert_game(game)
			if ok:
				recently_added.append(game.id)
		elif game.has('updated_at'):
			# update game
			ok = update_game(game)

			if game.has("expressions"):
				ok = update_game_expressions(game.id, game.expressions)
				if ok and stored_game.game_updated_at < int(game.updated_at):
					recently_modified.append(game.id)
		else:
			# update game order
			ok = update_game_order(game)

		if game.has("icon") and game.icon.has("url") and game.icon.url != null:
			request(game.icon.url)
			# result, response_code, headers, body
			var res = yield(self, 'request_completed')
			if res[1] == 200:
				update_game_image(game, res[3])

		if game.has("icon_base") and game.icon_base.has("url") and game.icon_base.url != null and game.icon_base.has("name") and game.icon_base.name != null:
			var image_path = Const.ICON_BASE_PATH + game.icon_base.name + ".png"
			if file_exists(image_path):
				print("SKIPPING: Base image already exists")
				update_game_image_base(game, null)
			else:
				print("Base image does not exist! Downloading...")
				request(game.icon_base.url)
				# result, response_code, headers, body
				var res = yield(self, 'request_completed')
				if res[1] == 200:
					update_game_image_base(game, res[3])

		print("Result: ", ok)
	emit_signal("database_updated", ok)
	return ok


func close_db():
	return db.close()


func save_image(image_path, body):
	var image = Image.new()
	var res = image.load_png_from_buffer(body)
	if res != OK:
		return false
	res = image.save_png(image_path)
	if res != OK:
		return false
	return image_path


func get_saved_games():
	return db.fetch_array(
		"""SELECT * 
		FROM SavedGame  
		ORDER BY saved_game_created_at desc;"""
	)


func get_saved_game_teams(saved_game_id):
	return db.fetch_array_with_args(
		"""SELECT * 
		FROM SavedGameTeam 
		WHERE saved_game_team_saved_game=? 
		ORDER BY saved_game_team_number asc;""",
		[saved_game_id]
	)


func insert_saved_game(n_teams, saved_game):
	print("Inserting new saved game...")
	var values = [saved_game, OS.get_unix_time(), 0]
	for value in values:
		if value == null:
			return false
	var ok = db.query_with_args("""
		INSERT INTO SavedGame (saved_game_name, saved_game_created_at, saved_game_next_team) 
		VALUES (?, ?, ?);
	""", values
	)
	if not ok:
		return false
	var saved_game_id = db.fetch_array("""
		SELECT max(saved_game_id) from SavedGame;
	"""
	)
	print("Max id: ", saved_game_id[0][0])
	ok = insert_saved_game_teams(n_teams, saved_game_id[0][0])
	if not ok:
		return false
	return get_saved_game_and_results(saved_game_id[0][0])
  

func insert_saved_game_teams(n_teams, saved_game_id):
	if n_teams < 2:
		print("Less than 2 teams")
		return true
	print("Inserting new teams...")
	var ok
	for i in range(n_teams):
		ok = db.query_with_args("""
			INSERT INTO SavedGameTeam (
				saved_game_team_number, saved_game_team_saved_game, 
				saved_game_team_score
			) VALUES (?, ?, ?);
		""", [i, saved_game_id, 0]
		)
		if not ok:
			return ok
	return ok


func get_saved_games_and_results():
	var saved_games = db.fetch_array(
		"""SELECT * 
		FROM SavedGame 
		ORDER BY saved_game_created_at desc;"""
	)
	var saved_games_and_results = []
	for saved_game in saved_games:
		var teams = get_saved_game_teams(saved_game["saved_game_id"])
		saved_game["results"] = teams
		saved_games_and_results.append(saved_game)

	return saved_games_and_results


func get_saved_game_and_results(saved_game_id):
	var saved_game = db.fetch_array_with_args(
		"""SELECT * 
		FROM SavedGame 
		WHERE saved_game_id=?;""", [saved_game_id]
	)
	var teams = get_saved_game_teams(saved_game_id)
	saved_game[0]["results"] = teams

	return saved_game[0]


func format_unix_time(unix_time):
	var datetime = OS.get_datetime_from_unix_time(unix_time)
	var date = str(datetime["day"]) + "-" + str(datetime["month"]) + "-" + str(datetime["year"])
	var time = str(datetime["hour"]) + ":" + str(datetime["minute"]) + ":" + str(datetime["second"])
	return date + " " + time


func add_score(saved_game_id, team_number, score):
	return db.query_with_args(
		"""UPDATE SavedGameTeam SET saved_game_team_score=saved_game_team_score+? 
		WHERE saved_game_team_saved_game = ? AND 
		saved_game_team_number = ?
		""", [score, saved_game_id, team_number]
	)


func next_team(saved_game_id, team_number):
	return db.query_with_args(
		"""UPDATE SavedGame SET saved_game_next_team=? 
		WHERE saved_game_id = ? 
		""", [team_number, saved_game_id]
	)


func reset_saved_game(saved_game_id):
	var ok = db.query_with_args(
		"""UPDATE SavedGame 
		SET saved_game_next_team = 0 
		WHERE saved_game_id = ? 
		""", [saved_game_id]
	)
	if not ok:
		return ok
	return db.query_with_args(
		"""UPDATE SavedGameTeam 
		SET saved_game_team_score = 0 
		WHERE saved_game_team_saved_game = ? 
		""", [saved_game_id]
	)


func remove_saved_game(saved_game_id):
	var ok = db.query_with_args(
		"""DELETE FROM SavedGame 
		WHERE saved_game_id = ? 
		""", [saved_game_id]
	)
	if not ok:
		return ok
	return db.query_with_args(
		"""DELETE FROM SavedGameTeam 
		WHERE saved_game_team_saved_game = ? 
		""", [saved_game_id]
	)
