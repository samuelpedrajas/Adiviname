extends ScrollContainer

enum Filters {
	FILTER_HOME=0,
	FILTER_RECENTLY_ADDED=1,
	FILTER_NORMAL=2,
	FILTER_GESTURES=3
}

var current_filter = Filters.FILTER_HOME

signal filters_changed


func get_games():
	if current_filter == Filters.FILTER_HOME:
		return DB.get_games_ordered_by_clicks()
	elif current_filter == Filters.FILTER_RECENTLY_ADDED:
		return DB.get_games_ordered_by_creation_date()
	elif current_filter == Filters.FILTER_NORMAL:
		return DB.get_normal_games_ordered_by_clicks()
	elif current_filter == Filters.FILTER_GESTURES:
		return DB.get_gesture_games_ordered_by_clicks()


func _untoggle_buttons():
	for btn in get_tree().get_nodes_in_group("filter"):
		btn.set_pressed(false)


func set_home_filter():
	_untoggle_buttons()
	$HBoxContainer/Home.set_pressed(true)
	current_filter = Filters.FILTER_HOME


func set_last_added_filter():
	_untoggle_buttons()
	$HBoxContainer/LastAdded.set_pressed(true)
	current_filter = Filters.FILTER_RECENTLY_ADDED


func set_description_filter():
	_untoggle_buttons()
	$HBoxContainer/Description.set_pressed(true)
	current_filter = Filters.FILTER_NORMAL


func set_gestures_filter():
	_untoggle_buttons()
	$HBoxContainer/Gestures.set_pressed(true)
	current_filter = Filters.FILTER_GESTURES


func _on_Home_pressed():
	set_home_filter()
	emit_signal("filters_changed")


func _on_LastAdded_pressed():
	set_last_added_filter()
	emit_signal("filters_changed")


func _on_Description_pressed():
	set_description_filter()
	emit_signal("filters_changed")


func _on_Gestures_pressed():
	set_gestures_filter()
	emit_signal("filters_changed")
