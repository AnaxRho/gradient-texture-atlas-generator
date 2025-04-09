@tool
# class_name Logger
extends Node

#region Enums
enum LogLevel {ERROR, WARN, INFO, DEBUG}
#endregion

#region Consts
const LOG_FORMAT_STACK = "%s [%s] %s.%s:%d: %s"
const LOG_FORMAT_SIMPLE = "%s [%s]: %s"
const LEVEL_FORMAT = "[color=%s]%s[/color]"

#region Static Variables
static var INFO_TEXT: String = LEVEL_FORMAT % ['white', 'INFO']
static var DEBUG_TEXT: String = LEVEL_FORMAT % ['green', 'DEBUG']
static var WARN_TEXT: String = LEVEL_FORMAT % ['purple', 'WARN']
static var ERROR_TEXT: String = LEVEL_FORMAT % ['red', 'ERROR']
#endregion

#region Variables
var info_enabled: bool = true
var debug_enabled: bool = true
var warn_enabled: bool = true
var trace_enabled: bool = true

var remote_debug: bool = false
#endregion

#region Private Methods
func _ready() -> void:
	_test_remote_debug()

func _test_remote_debug():
	remote_debug = get_stack() != null
	if remote_debug:
		Logger.debug("Remote debug is enabled")

static func _get_stack_info():
	var stack: Array = get_stack()
	return stack[-1] if stack and stack.size() > 0 else null

static func _replace_source(source: String) -> String:
	var result: String = source.split('/')[-1]
	return result

static func _get_level_text(level: LogLevel) -> String:
	var text: String
	match level:
		LogLevel.ERROR:
			text = ERROR_TEXT
		LogLevel.DEBUG:
			text = DEBUG_TEXT
		LogLevel.WARN:
			text = WARN_TEXT
		LogLevel.INFO:
			text = INFO_TEXT
		_:
			text = ''
	return text

func _log(level: LogLevel, text: String) -> void:
	var log_message: String
	var level_text: String = _get_level_text(level)
	var unixtime: float = Time.get_unix_time_from_system()
	var millis: float = int(1000.0 * fmod(unixtime, 1.0))
	var dt: String = '%s.%03d' % [Time.get_datetime_string_from_unix_time(int(unixtime), true), millis]
	if remote_debug:
		var stack_info = _get_stack_info()
		if stack_info:
			var source: String = _replace_source(stack_info['source'])
			log_message = LOG_FORMAT_STACK % [dt, level_text, source, stack_info['function'], stack_info['line'], text]
		else:
			log_message = LOG_FORMAT_SIMPLE % [dt, level_text, text]
	else:
		log_message = LOG_FORMAT_SIMPLE % [dt, level_text, text]
	print_rich(log_message)
#endregion

#region Public Methods
func debug(text: String) -> void:
	if debug_enabled:
		_log(LogLevel.DEBUG, text)

func warn(text: String) -> void:
	push_warning(text)
	if warn_enabled:
		_log(LogLevel.WARN, text)

func info(text: String) -> void:
	if info_enabled:
		_log(LogLevel.INFO, text)

func error(text: String) -> void:
	push_error(text)
	_log(LogLevel.ERROR, text)
#endregion

#region Tests
func test_print() -> void:
	error("Error")
	warn("Warn")
	info("Info")
	debug("Debug")
#endregion
