extends HSplitContainer


func setup(name, score):
	$TextureRect/Team.set_text(name)
	$Score/Score.set_text(str(score))
