extends Node

var current_scene = "main"

var title
var description
var expressions

var main_scene = preload("res://scenes/Main.tscn")
var expression_screen_scene = preload("res://scenes/ExpressionScreen.tscn")


func _ready():
	randomize()
	get_tree().set_quit_on_go_back(false)


func load_game(title, description, expressions):
	self.title = title
	self.description = description
	self.expressions = expressions

	current_scene = "expression_screen"
	get_tree().change_scene_to(expression_screen_scene)
	OS.set_screen_orientation(0)


func load_main_scene():
	current_scene = "main"
	get_tree().change_scene_to(main_scene)
	OS.set_screen_orientation(1)


func quit_game():
	get_tree().quit()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if current_scene != "main":
			load_main_scene()
		else:
			quit_game()
	elif what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if current_scene != "main":
			load_main_scene()
		else:
			quit_game()
