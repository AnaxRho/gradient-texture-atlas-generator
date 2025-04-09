@tool
extends Control

##
##

#region Consts
#endregion

#region Enums
#endregion

#region Exports
@export var atlas: GradientTextureAtlas = GradientTextureAtlas.new()

@export_category("Controls")
@export_tool_button("Update", "Callable") var callable = _update_texture
#endregion

#region Static variables
static var PRESET_OPTIONS: Dictionary[String, Palette] = {
	"Extended": preload("res://palette/presets/expanded.tres"),
	"Pastel": preload("res://palette/presets/pastel.tres"),
	"Noir": preload("res://palette/presets/noir.tres"),
	"": null,
}
#endregion

#region Nodes
@onready var columns_spin_box: SpinBox = %ColumnsSpinBox
@onready var rows_spin_box: SpinBox = %RowsSpinBox

@onready var region_width_spin_box: SpinBox = %RegionWidthSpinBox
@onready var region_height_spin_box: SpinBox = %RegionHeightSpinBox

@onready var gradient_mode_option_button: OptionButton = %GradientModeOptionButton
@onready var gradient_factor_spin_box: SpinBox = %GradientFactorSpinBox
@onready var gradient_quants_spin_box: SpinBox = %GradientQuantsSpinBox

@onready var preset_option_button: OptionButton = %PresetOptionButton
@onready var background_color_picker_button: ColorPickerButton = %BackgroundColorPickerButton
@onready var colors_count_spin_box: SpinBox = %ColorsCountSpinBox

@onready var colors_container: GridContainer = %ColorsContainer

@onready var texture_size_edit: LineEdit = %TextureSizeEdit
@onready var texture_rect: TextureRect = %TextureRect

@onready var zoom_slider: HSlider = %ZoomSlider
@onready var zoom_value_label: Label = %ZoomValueLabel

@onready var file_dialog: FileDialog = %FileDialog

@onready var popup_panel: PopupPanel = %PopupPanel

@onready var about_text: TextEdit = %AboutText
@onready var license_text: TextEdit = %LicenseText
#endregion

#region Variables
#endregion

#region Private methods
func _ready() -> void:
	_add_gradient_mode_options()
	_add_preset_options()

	about_text.text = ProjectSettings.get_setting("application/config/description")
	license_text.text = Engine.get_license_text()

	columns_spin_box.value = atlas.layout.x
	colors_container.columns = atlas.layout.x
	rows_spin_box.value = atlas.layout.y

	region_width_spin_box.value = atlas.region_size.x
	region_height_spin_box.value = atlas.region_size.y

	gradient_mode_option_button.selected = atlas.gradient_mode
	gradient_factor_spin_box.value = atlas.gradient_factor
	gradient_quants_spin_box.value = atlas.gradient_quants

	background_color_picker_button.color = atlas.background_color

	_update_texture_size()

	atlas.palette = PRESET_OPTIONS.values()[preset_option_button.selected]
	
	if atlas.palette != null:
		_update_colors_area(atlas.palette.size())
		gradient_quants_spin_box.value = int(atlas.palette.size())

func _add_gradient_mode_options() -> void:
	gradient_mode_option_button.clear()
	for mode in GradientTextureAtlas.GradientMode.keys():
		gradient_mode_option_button.add_item(mode)

func _add_preset_options() -> void:
	preset_option_button.clear()
	for preset in PRESET_OPTIONS.keys():
		preset_option_button.add_item(preset)

func _add_color_picker(idx: int) -> void:
	var picker: ColorPickerButton = ColorPickerButton.new()
	picker.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	picker.custom_minimum_size = Vector2i(48, 27)
	picker.color_changed.connect(on_palette_color_picker_color_changed.bind(idx))
	var palette_colors: Array[Color] = atlas.palette.get_colors()
	if palette_colors.size() > idx:
		picker.color = palette_colors[idx]
	colors_container.add_child(picker)

func _update_colors_area(count: int) -> void:
	for child in colors_container.get_children():
		colors_container.remove_child(child)
	for i in range(0, atlas.palette.size()):
		_add_color_picker(i)
	if atlas.palette.size() < count:
		for i in range(atlas.palette.size(), count):
			_add_color_picker(i)

func _update_texture() -> void:
	if atlas != null:
		atlas.generate()
		texture_rect.texture = atlas.get_texture()
		texture_rect.scale.x = zoom_slider.value
		texture_rect.scale.y = zoom_slider.value

func _save_texture(path: String) -> void:
	Logger.info('%s' % path)
	atlas.get_image().save_png(path)

func _update_texture_size() -> void:
	texture_size_edit.text = '%.0v' % atlas.get_texture_size()
#endregion

#region Public methods
#endregion

#region Signal handlers
func on_palette_color_picker_color_changed(color: Color, idx: int) -> void:
	atlas.palette.set_color(idx, color)

func _on_columns_spin_box_value_changed(value: float) -> void:
	atlas.layout.x = int(value)
	colors_container.columns = atlas.layout.x
	_update_texture_size()

func _on_rows_spin_box_value_changed(value: float) -> void:
	atlas.layout.y = int(value)
	_update_texture_size()

func _on_region_width_spin_box_value_changed(value: float) -> void:
	atlas.region_size.x = int(value)
	_update_texture_size()

func _on_region_height_spin_box_value_changed(value: float) -> void:
	atlas.region_size.y = int(value)
	_update_texture_size()

func _on_background_color_picker_button_color_changed(color: Color) -> void:
	atlas.background_color = color

func _on_gradient_mode_option_button_item_selected(index: int) -> void:
	var mode: GradientTextureAtlas.GradientMode = index as GradientTextureAtlas.GradientMode
	atlas.gradient_mode = mode

func _on_gradient_quants_spin_box_value_changed(value: float) -> void:
	atlas.gradient_quants = int(value)

func _on_gradient_factor_spin_box_value_changed(value: float) -> void:
	atlas.gradient_factor = value

func _on_colors_count_spin_box_value_changed(value: float) -> void:
	_update_colors_area(int(value))

func _on_preset_option_button_item_selected(index: int) -> void:
	atlas.palette = PRESET_OPTIONS.values()[index]
	_update_colors_area(atlas.palette.size())
	colors_count_spin_box.value = int(atlas.palette.size())

func _on_zoom_slider_value_changed(value: float) -> void:
	zoom_value_label.text = "%0.2f" % value
	texture_rect.scale.x = value
	texture_rect.scale.y = value

func _on_update_button_pressed() -> void:
	_update_texture()

func _on_save_button_pressed() -> void:
	file_dialog.show()

func _on_file_dialog_file_selected(path: String) -> void:
	_save_texture(path)

func _on_popup_menu_index_pressed(index: int) -> void:
	match index:
		0:
			popup_panel.show()
		1: 
			get_tree().quit()

func _on_license_close_button_pressed() -> void:
	popup_panel.hide()
#endregion
