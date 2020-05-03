tool
extends Node
class_name AsepriteImportData


enum Error{
	OK,
	ERR_JSON_PARSE_ERROR,
	ERR_INVALID_JSON_DATA,
}


const FRAME_TEMPLATE = {
	frame = {
		x = TYPE_INT,
		y = TYPE_INT,
		w = TYPE_INT,
		h = TYPE_INT,
	},
	spriteSourceSize = {
		x = TYPE_INT,
		y = TYPE_INT,
		w = TYPE_INT,
		h = TYPE_INT,
	},
	sourceSize = {
		w = TYPE_INT,
		h = TYPE_INT,
	},
	duration = TYPE_INT,
}

const META_TEMPLATE = {
	frameTags = [
		{
			name = TYPE_STRING,
			from = TYPE_INT,
			to = TYPE_INT,
			direction = TYPE_STRING
		},
	],
	size = {
		w = TYPE_INT,
		h = TYPE_INT,
	},
}


var json_filepath : String
var json_data : Dictionary


func load(filepath : String) -> int:
	var file := File.new()

	var error := file.open(filepath, File.READ)
	if error != OK:
		return error

	var file_text = file.get_as_text()
	file.close()

	var json := JSON.parse(file_text)
	if json.error != OK:
		return Error.ERR_JSON_PARSE_ERROR

	if not _validate_json(json):
		return Error.ERR_INVALID_JSON_DATA

	json_filepath = filepath
	json_data = json.result

	return OK


func get_frame_array() -> Array:
	if not json_data:
		return []

	var frame_data = json_data.frames
	if frame_data is Dictionary:
		return frame_data.values()

	return frame_data


func get_image_filename() -> String:
	if not (json_data and json_data.meta.has("image")):
		return ""

	return json_data.meta.image


func get_image_size() -> Vector2:
	if not json_data:
		return Vector2.ZERO

	var image_size : Dictionary = json_data.meta.size
	return Vector2(
		image_size.w,
		image_size.h
	)


func get_tag(tag_idx : int) -> Dictionary:
	var tags := get_tags()

	if tag_idx >= 0 and tag_idx < tags.size():
		return tags[tag_idx]

	return {}


func get_tags() -> Array:
	if not json_data:
		return []

	return json_data.meta.frameTags


static func _validate_json(json : JSONParseResult) -> bool:
	var data : Dictionary = json.result

	if not (data is Dictionary and data.has_all(["frames", "meta"])):
		return false

	# "frames" validation
	var frames = data.frames
	var is_hash := frames is Dictionary

	for frame in frames:
		if is_hash:
			frame = frames[frame]

		if not _match_template(frame, FRAME_TEMPLATE):
			return false

	# "meta" validation
	return _match_template(data.meta, META_TEMPLATE)


"""
This helper function recursively walks an Array or a Dictionary checking if each
children's type matches the template
"""
static func _match_template(data, template) -> bool:
	match typeof(template):
		TYPE_INT:
			# When parsed, the JSON interprets integer values as floats
			if template == TYPE_INT and typeof(data) == TYPE_REAL:
				return true
			return typeof(data) == template
		TYPE_DICTIONARY:
			if typeof(data) != TYPE_DICTIONARY:
				return false

			if not data.has_all(template.keys()):
				return false

			for key in template:
				if not _match_template(data[key], template[key]):
					return false
		TYPE_ARRAY:
			if typeof(data) != TYPE_ARRAY:
				return false

			if data.empty():
				return false

			for element in data:
				if not _match_template(element, template[0]):
					return false

	return true
