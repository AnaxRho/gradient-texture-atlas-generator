@tool
class_name GradientTextureAtlas
extends Resource

##
##

#region Consts
#endregion

#region Enums
enum GradientMode {DARKEN}
#endregion

#region Exports
@export_group('Layout')
@export var layout: Vector2i = Vector2i(4, 2): set = _set_layout
@export var region_size: Vector2i = Vector2(1, 32)
@export_group('Gradient')
@export var gradient_mode: GradientMode = GradientMode.DARKEN
@export_range(1, 256, 1) var gradient_quants: int = 8
@export_range(0, 10, 0.1) var gradient_factor: float = 0.5
@export_group('Base Colors')
@export var palette: Palette = Palette.new()
@export var background_color: Color = Color.BLACK
#endregion

#region Static variables
#endregion

#region Variables
var _image: Image
#endregion

#region Private methods
func _is_valid() -> void:
	if palette != null:
		if layout.x * layout.y < palette.get_colors().size():
			push_warning("Not enough space to fit all colors")

func _set_layout(new_value: Vector2i) -> void:
	layout.x = clamp(new_value.x, 1, 256)
	layout.y = clamp(new_value.y, 1, 256)
	_is_valid()

@warning_ignore("integer_division")
func _get_region_rect(idx: int) -> Rect2i:
	var col: int = idx % layout.x
	var row: int = idx / layout.x
	var pos: Vector2i = Vector2i(col * region_size.x, row * region_size.y)
	return Rect2i(pos, region_size)

static func _modify_color(base_color: Color, mode: GradientMode, factor: float, quants: int, index: int) -> Color:
	var delta: float = factor / quants
	var amount: float = index * delta
	Logger.debug('amount: %0.3f' % amount)
	var new_color: Color
	match mode:
		GradientMode.DARKEN:
			new_color = base_color.darkened(amount)
	return new_color

@warning_ignore("integer_division")
static func _fill_image_region(source: Image, region: Rect2i, base_color: Color, mode: GradientMode, factor: float, quants: int) -> Image:
	var size: Vector2i = Vector2i(region.size.x, region.size.y / quants)
	for i in range(0, quants):
		var color: Color = _modify_color(base_color, mode, factor, quants, i)
		var pos: Vector2i = Vector2i(region.position.x, region.position.y + i * size.y)
		var rect: Rect2i = Rect2i(pos, size)
		Logger.debug("Filling gradient subdivision region #%d: pos=%s size=%s" % [i, rect.position, rect.size])
		source.fill_rect(rect, color)
	return source

func _generate_image() -> Image:
	Logger.debug("Region size: %s" % region_size)
	var final_size: Vector2i = Vector2i(layout.x * region_size.x, layout.y * region_size.y)
	Logger.debug("Texture size: %s" % final_size)
	var image: Image = Image.create_empty(final_size.x, final_size.y, false, Image.FORMAT_RGBA8)
	if background_color != null:
		image.fill_rect(Rect2i(0, 0, final_size.x, final_size.y), background_color)
	var i: int = 0
	for color in palette.get_colors():
		var region: Rect2i = _get_region_rect(i)
		Logger.debug("Filling palette color region #%d: pos=%s size=%s" % [i, region.position, region.size])
		image = _fill_image_region(image, region, color, gradient_mode, gradient_factor, gradient_quants)
		i += 1
	return image
#endregion

#region Public methods
func set_color(idx: int, color: Color) -> void:
	if palette != null:
		palette._colors[idx] = color

func get_texture_size() -> Vector2i:
	return Vector2i(layout.x * region_size.x, layout.y * region_size.y)

func generate() -> Image:
	_image = _generate_image()
	return _image

func get_image() -> Image:
	if _image == null:
		_image = _generate_image()
	return _image

func get_texture() -> ImageTexture:
	return ImageTexture.create_from_image(get_image())
#endregion
