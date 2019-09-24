extends Node

var game_name = "Game"
var game_description = "Example"
var game_mode = Const.GameMode.NORMAL


func setup(game_name, game_description, game_mode):
	self.game_name = game_name
	self.game_description = game_description
	self.game_mode = game_mode
