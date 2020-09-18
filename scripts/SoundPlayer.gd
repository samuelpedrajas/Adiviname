extends Node


func play_sound(name):
	var sound_effect = get_node(name)
	sound_effect.play()
