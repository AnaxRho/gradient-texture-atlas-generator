@tool
class_name Palette
extends Resource

##
##

#region Exports
@export var _colors: Array[Color]
#endregion

#region Public methods
func _init() -> void:
	_colors = [Color.WHITE]

func get_colors() -> Array[Color]:
	return _colors

func size() -> int:
	return _colors.size()
#endregion
