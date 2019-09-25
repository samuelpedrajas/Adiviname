extends Control

var title
var description
var expressions


func setup(title, description, expressions):
	self.title = title
	self.description = description
	self.expressions = expressions

	$Button/Title.set_text(title)
	$Button/Description.set_text(description)


func _on_Button_pressed():
	if not get_parent().get_parent().swiping:
		Global.load_game(title, description, expressions)
