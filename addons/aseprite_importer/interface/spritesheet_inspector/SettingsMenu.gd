tool
extends Container


onready var options : Container = $Options


const PROP_TO_MENU := {
	frame_border = "FrameBorder",
	selection_border = "SelectionBorder",
	texture_background = "TextureBackground",
	inspector_background = "InspectorBackground",
	aseprite_command = "AsepriteCommand",
}

const DEFAULT_SETTINGS :={
	frame_border = {
		color = Color("#808080"),
		visibility = true,
	},
	selection_border = {
		color = Color.yellow,
		visibility = true,
	},
	texture_background = {
		color = Color("#404040"),
		visibility = true,
	},
	inspector_background = {
		color = Color.black,
	},
	aseprite_command = "aseprite"
}


var settings := DEFAULT_SETTINGS.duplicate(true) setget set_settings


signal settings_changed(settings)


func _ready():
	for property in PROP_TO_MENU:
		var node_name : String = PROP_TO_MENU[property]
		var menu := options.get_node(node_name)

		menu.set_meta("property", property)
		menu.connect("property_changed", self, "_on_property_changed")


# Setters and Getters
func set_settings(new_settings : Dictionary) -> void:
	if new_settings:
		settings = new_settings
	else:
		settings = DEFAULT_SETTINGS.duplicate(true)

	for property in PROP_TO_MENU:
		var node_name : String = PROP_TO_MENU[property]
		var menu = options.get_node(node_name)
		var menu_type : String = menu.get_meta("menu_type")

		match menu_type:
			"color_menu":
				menu.color_value = settings[property].color
				menu.visibility = settings[property].get("visibility", false)
			"text_menu":
				menu.field_text = settings[property]
		
	emit_signal("settings_changed", settings)


# Signal Callbacks
func _on_property_changed(menu_item : Node) -> void:
	var property : String = menu_item.get_meta("property")
	var menu_type : String = menu_item.get_meta("menu_type")

	match menu_type:
		"color_menu":
			settings[property]["color"] = menu_item.color_value
			settings[property]["visibility"] = menu_item.visibility
		"text_menu":
			settings[property] = menu_item.field_text
	
	emit_signal("settings_changed", settings)
