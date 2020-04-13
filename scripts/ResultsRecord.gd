extends Control

var record_index
var text

signal selection_changed

func setup(text, checked, record_index):
	self.record_index = record_index
	$CheckBox.set_pressed(checked)
	self.text = text

# after setup
func _ready():
	var label = $CheckBox/Text
	var label_size = 1.0 * label.rect_size
	var label_position = 1.0 * label.get_position()
	var font = label.get_font("font")
	var font_size = 1.0 * font.get_size()
	print("SIZEEE: ", font_size)
	print(font)
	print($CheckBox/Text.get_font("font"))
	label.set_text(text)

	var words = text.split(" ", false)
	var longest_word = ""
	for i in words:
		if font.get_string_size(i).x > font.get_string_size(longest_word).x:
			longest_word = i
	var word_length = font.get_string_size(longest_word).x

	if word_length > label_size.x:
		font.set_size(label_size.x / word_length * font_size * 0.95)

	label.rect_size = label_size
	label.set_position(label_position)


func _on_CheckBox_toggled(button_pressed):
	if not get_parent().get_parent().swiping:
		emit_signal("selection_changed", record_index, button_pressed)
	else:
		$CheckBox.set_pressed(not button_pressed)
