tool
extends Container

signal generated_json(json_file, sprite_sheet)

var editor_filesystem : EditorFileSystem
var aseprite_command := "aseprite"

# Childs
onready var import_button : Button = $InputContainer/ImportButton
onready var file_dialog : FileDialog = $FileDialog
onready var alert_dialog : AcceptDialog = $AlertDialog

# Messages
const MSG_IMPORT_FILE_ERROR = \
	"An error occurred while opening the importing file \"%s\"\n\n" + \
	"(error code: %d)"
const MSG_ASEPRITE_CMD_NOT_FOUND = \
	"Aseprite executable command not found.\n" + \
	"You need Aseprite installed to use this feature.\n" + \
	"Insert a valid executable path in the settings tab on the right."
const MSG_SOURCE_FILE_NOT_FOUND = "Could't find the source file."
const MSG_OUTPUT_FOLDER_NOT_FOUND = "Could't find the output folder directory."
const MSG_ASEPRITE_EXPORT_FAILED = "Aseprite failed to export the files."
const MSG_UNKNOWN_EXPORT_MODE = "Unknown export mode."
const MSG_NO_VALID_LAYERS_FOUND = "No valid layers found."
const MSG_INVALID_ASEPRITE_SPRITESHEET = "Invalid Aseprite spritesheet."





func _ready():
	alert_dialog.set_as_toplevel(true)
	
	# Connect Children Signals
	import_button.connect("pressed", self, "_on_ImportButton_pressed")
	file_dialog.connect("file_selected", self, "_on_file_selected")


func _update_theme(editor_theme : EditorTheme) -> void:
	import_button.icon = editor_theme.get_icon("Load")


# Signal Callbacks
func _on_plugin_data_received(plugin_data : Dictionary):
	editor_filesystem = plugin_data.get("editor_filesystem")


func _on_settings_changed(settings : Dictionary):
	aseprite_command = settings.get("aseprite_command", aseprite_command)


func _on_ImportButton_pressed() -> void:
	file_dialog.invalidate()
	file_dialog.popup_centered_ratio(0.5)


func _on_file_selected(file_path : String) -> void:
	
	var asepriteCMD : AsepriteCMD = AsepriteCMD.new()
	asepriteCMD.init(aseprite_command, editor_filesystem)
	
	var output_dir =  file_path.get_base_dir()
	var basename = asepriteCMD._get_file_basename(file_path)
	var json_file = "%s/%s.json" % [output_dir, basename]
	var sprite_sheet = "%s/%s.png" % [output_dir, basename]
	
	var options := {
		# Changeable:
		export_mode = AsepriteCMD.FILE_EXPORT_MODE,
		exception_pattern = "",
		only_visible_layers = false,
		trim_images = false,
		output_filename = "",
	}

	var error = asepriteCMD.create_resource(
		file_path.replace("res://", "./"), 
		output_dir.replace("res://", "./"), 
		options
	)
	
	if error is GDScriptFunctionState:
		error = yield(error, "completed")

	if error != AsepriteCMD.SUCCESS:
		var error_msg : String

		match error:
			AsepriteCMD.ERR_ASEPRITE_CMD_NOT_FOUND:
				error_msg = MSG_ASEPRITE_CMD_NOT_FOUND
			AsepriteCMD.ERR_SOURCE_FILE_NOT_FOUND:
				error_msg = MSG_SOURCE_FILE_NOT_FOUND
			AsepriteCMD.ERR_OUTPUT_FOLDER_NOT_FOUND:
				error_msg = MSG_OUTPUT_FOLDER_NOT_FOUND
			AsepriteCMD.ERR_ASEPRITE_EXPORT_FAILED:
				error_msg = MSG_ASEPRITE_EXPORT_FAILED
			AsepriteCMD.ERR_UNKNOWN_EXPORT_MODE:
				error_msg = MSG_UNKNOWN_EXPORT_MODE
			AsepriteCMD.ERR_NO_VALID_LAYERS_FOUND:
				error_msg = MSG_NO_VALID_LAYERS_FOUND
			AsepriteCMD.ERR_INVALID_ASEPRITE_SPRITESHEET:
				error_msg = MSG_INVALID_ASEPRITE_SPRITESHEET
			_:
				error_msg = MSG_IMPORT_FILE_ERROR % [file_path, error]

		yield(get_tree(), "idle_frame")
		alert_dialog.dialog_text = error_msg
		alert_dialog.popup_centered()
	else:
		emit_signal("generated_json", json_file, sprite_sheet)
