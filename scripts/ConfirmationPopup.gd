extends Control

var caller
var yes_func_name
var no_func_name


func _ready():
	if Main.current_scene == "expression_screen":
		var r = rect_size.x / rect_size.y
		$Content.rect_size *= r
		$Content.rect_position -= $Content.rect_size / 4.0
		$Content/Buttons.rect_size *= r
		$Content/Buttons.rect_position -= $Content/Buttons.rect_size / 4.0
		$Content/Buttons/Yes.rect_size *= r
		$Content/Buttons/Yes.rect_position -= $Content/Buttons/Yes.rect_size / 4.0
		$Content/Buttons/No.rect_size *= r
		$Content/Buttons/No.rect_position -= $Content/Buttons/No.rect_size / 4.0

		var q_font = $Content/Question.get_font("font")
		var q_font_new = get_new_font(
			q_font.get_size() * r,
			q_font.font_data
		)
		$Content/Question.add_font_override("font", q_font_new)

		var a_font = $Content/Buttons/Yes/Text.get_font("font")
		var a_font_new = get_new_font(
			a_font.get_size() * r,
			a_font.font_data
		)
		$Content/Buttons/Yes/Text.add_font_override("font", a_font_new)
		$Content/Buttons/No/Text.add_font_override("font", a_font_new)


func get_new_font(s, font_data):
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = font_data
	dynamic_font.size = s
	dynamic_font.use_filter = true
	dynamic_font.use_mipmaps = true
	return dynamic_font


func setup(question, caller, yes_func_name, no_func_name):
	self.caller = caller
	self.yes_func_name = yes_func_name
	self.no_func_name = no_func_name

	$Content/Question.set_text(question)


func _on_Yes_pressed():
	var _caller = caller
	var _yes_func_name = yes_func_name
	Main.close_popups()
	if _yes_func_name != null:
		_caller.call(_yes_func_name)


func _on_No_pressed():
	var _caller = caller
	var _no_func_name = no_func_name
	Main.close_popups()
	if _no_func_name != null:
		_caller.call(_no_func_name)


func _on_ConfirmationPopup_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var _caller = caller
			var _no_func_name = no_func_name
			Main.close_popups()
			if _no_func_name != null:
				_caller.call(_no_func_name)
