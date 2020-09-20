tool
extends EditorScript


var saved_images_path = "res://saved_images/"
var bases_path = "res://saved_images/bases/"

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files


func get_texture(img_path):
	var image = Image.new()
	var err = image.load(img_path)
	if err != OK:
		return
	var texture = ImageTexture.new()
	texture.set_flags(ImageTexture.FLAG_FILTER)
	texture.create_from_image(image, 0)
	return texture


func process_files(path):
	var img_names = list_files_in_directory(path)
	for img_name in img_names:
		var img_path = path + img_name
		if not img_path.ends_with(".png"):
			continue

		print("Processing: ", img_path)
		var tex = get_texture(img_path)

		var output_path = img_path.replace(".png", ".tres")
		ResourceSaver.save(output_path, tex)


func _run():
	print("ENTRANDO")
	if not Engine.editor_hint:
		return

	#process_files(saved_images_path)
	process_files(bases_path)
	print("SALIENDO")
