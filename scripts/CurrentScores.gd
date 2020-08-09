extends GridContainer

var TeamCurrentScore = preload("res://scenes/TeamCurrentScore.tscn")
var current_team
var current_score = 0


func set_scores(current_score):
	if not Main.team_mode:
		return
	var scores = DB.get_saved_game_teams(
		Main.saved_game.saved_game_id
	)
	var n_teams = scores.size()
	for i in range(n_teams):
		var idx = i
		if idx % 2 == 0:
			idx /= 2
		else:
			var aux = n_teams
			if n_teams % 2 == 1:
				aux += 1
			idx = i + (aux / 2 - (i + 1) / 2)
		var score_entry = scores[idx]
		var tcs = TeamCurrentScore.instance()
		var team = score_entry.saved_game_team_number
		var score = score_entry.saved_game_team_score
		tcs.set_team_and_score(team, score)

		if team == Main.saved_game.saved_game_next_team:
			current_team = tcs
			tcs.set_current()
			update_current_team(current_score)

		add_child(tcs)


func update_current_team(score):
	current_team.update_score(
		score - current_score
	)
	current_score = score
