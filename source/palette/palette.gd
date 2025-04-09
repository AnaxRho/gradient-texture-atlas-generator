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
#endregion
