@tool
class_name Palette
extends Resource

##
##

#region Exports
@export var _colors: Array[Color]
#endregion

#region Private methods
func _init() -> void:
	_colors = [Color.WHITE]

#endregion

#region Public methods
func set_color(idx: int, color: Color) -> void:
	if _colors.size() > idx:
		_colors[idx] = color

func get_colors() -> Array[Color]:
	return _colors

func size() -> int:
	return _colors.size()

func as_text() -> String:
	var text: String = "Palette: "
	var i: int = 0
	for c in _colors:
		text += '%s' % c.to_html()
		if i < _colors.size() - 1:
			text += ', '
		i += 1
	return text
#endregion
