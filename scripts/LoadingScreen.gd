extends Control

var num_pages = 0


func grow_bar(percentage):
	print(percentage, "%")
	if not $ProgressBar.is_visible():
		$ProgressBar.show()
		$Text.hide()
	$ProgressBar.set_value(percentage)
