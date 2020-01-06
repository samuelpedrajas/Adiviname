extends Control

var selected = 0
var saved_games
var saved_game_list
var team_score_list

var saved_game_item_scene = preload("res://scenes/SavedGameListItem.tscn")
var team_score_scene = preload("res://scenes/TeamScore.tscn")


func open():
	$SavedGames/ScrollContainer.configure_custom_scrollbar()
	saved_game_list = $SavedGames/ScrollContainer/SavedGamesList
	team_score_list = $TeamScores/Scores
	saved_games = DB.get_saved_games_and_results()
	if saved_games.size() > 0:
		populate_saved_games()
		populate_team_scores()
	show()

func populate_saved_games():
	clear_game_list()
	var i = 0
	for saved_game in saved_games:
		var saved_game_item = saved_game_item_scene.instance()
		saved_game_item.setup(
			saved_game["saved_game_name"],
			saved_game["saved_game_created_at"],
			i == selected,
			i
		)
		saved_game_item.connect("item_pressed", self, "select_game")
		saved_game_list.add_child(saved_game_item)
		i += 1


func select_game(selected):
	print("Selected: ", selected)
	update_selected(false)
	self.selected = selected
	update_selected(true)

func update_selected(v):
	var saved_game_item = saved_game_list.get_child(selected)
	saved_game_item.selected = v
	saved_game_item.update_selected()
	populate_team_scores()

func populate_team_scores():
	clear_score_list()
	var saved_game = saved_games[selected]
	for team in saved_game["results"]:
		var team_score = team_score_scene.instance()
		team_score.setup(
			"Equipo " + str(team["saved_game_team_number"]),
			team["saved_game_team_score"]
		)
		team_score_list.add_child(team_score)

func clear_game_list():
	for child in saved_game_list.get_children():
		child.queue_free()

func clear_score_list():
	for team_scores in team_score_list.get_children():
		team_scores.queue_free()

func close():
	hide()

func _on_Button_pressed():
	close()
