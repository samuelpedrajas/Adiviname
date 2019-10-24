extends Control

export var selected = false

func _ready():
	if selected:
		$BgSelected.show()
	else:
		$Bg.show()
