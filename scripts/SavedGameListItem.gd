extends Button

export var selected = false
var index

signal item_pressed

func _ready():
	update_selected()

func update_selected():
	if selected:
		$BgSelected.show()
		$Bg.hide()
	else:
		$BgSelected.hide()
		$Bg.show()

func setup(name, unix_time, selected, current, i):
	self.index = i
	self.selected = selected
	$Name.set_text(name)
	$Date.set_text(DB.format_unix_time(unix_time))
	if current:
		$Current.show()

func _on_SavedGameListItem_pressed():
	print("Pressed")
	emit_signal("item_pressed", index)
