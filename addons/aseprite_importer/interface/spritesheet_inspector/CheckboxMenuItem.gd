tool
extends CheckBox

signal property_changed(checkbox_menu_item)

func _ready() -> void:
	self.set_meta("menu_type", "checkbox_menu")
	connect("pressed", self, "_on_pressed")


func _update_theme(editor_theme : EditorTheme) -> void:
	pass


# Signal Callbacks
func _on_pressed() -> void:
	emit_signal('property_changed', self)
