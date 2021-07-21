tool
extends Container


onready var label : Label = $Header/Label
onready var textEdit : TextEdit = $TextEdit

export var label_text := '' setget set_label_text
export(String, MULTILINE) var field_tooltip := "" setget set_field_tooltip
export(String, MULTILINE) var field_text := "" setget set_field_text
export var long_single_line := true setget set_long_single_line


signal property_changed(text_menu_item)


func _ready():
	self.set_meta("menu_type", "text_menu")
	
	self.label_text = label_text
	self.field_tooltip = field_tooltip
	self.field_text = field_text
	self.long_single_line = long_single_line

func _update_theme(editor_theme : EditorTheme) -> void:
	pass


# Setters and Getters
func set_label_text(text : String) -> void:
	label_text = text
	if label:
		label.text = label_text

func set_field_tooltip(text : String) -> void:
	field_tooltip = text
	if textEdit:
		textEdit.hint_tooltip = field_tooltip

func set_field_text(text : String) -> void:
	field_text = text
	if textEdit:
		textEdit.text = text
	
func set_long_single_line(value : bool) -> void:
	long_single_line = value
	
	if textEdit:
		textEdit.wrap_enabled = not long_single_line
		textEdit.rect_size.y = 40 if long_single_line else 140
	

# Signal Callbacks
func _on_TextEdit_text_changed() -> void:
	field_text = textEdit.text
	emit_signal("property_changed", self)
