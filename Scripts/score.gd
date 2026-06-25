extends Node

var high_score : int = 0
var last_score : int = 0
var printed_score : int = 0
var high_score_loaded : bool = false
# Called when the node enters the scene tree for the first time.

const PATH := "user://score.save"
const WEB_STORAGE_KEY := "flappy_bilo_high_score"

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_high_score() -> void:
	var file := FileAccess.open(PATH,FileAccess.WRITE)
	if file == null:
		push_warning("Could not save high score: " + error_string(FileAccess.get_open_error()))
	else:
		file.store_32(high_score)
		file.flush()
		file = null

	if OS.has_feature("web"):
		JavaScriptBridge.force_fs_sync()
		save_high_score_to_web_storage()
		if not OS.is_userfs_persistent():
			push_warning("Browser storage is not persistent. High score may not survive reloads on this device/browser.")

func load_high_score() -> void:
	if high_score_loaded:
		return

	high_score_loaded = true
	var saved_score := 0
	var file := FileAccess.open(PATH,FileAccess.READ)
	if file == null:
		print_debug("No save found: " + error_string(FileAccess.get_open_error()))
	else:
		saved_score = file.get_32()

	if OS.has_feature("web"):
		saved_score = max(saved_score, load_high_score_from_web_storage())

	high_score = saved_score

func save_high_score_to_web_storage() -> void:
	var js := """
		(function () {
			try {
				window.localStorage.setItem("%s", "%s");
				return true;
			} catch (error) {
				return false;
			}
		})()
	""" % [WEB_STORAGE_KEY, high_score]

	if not JavaScriptBridge.eval(js, true):
		push_warning("Could not save high score to browser localStorage.")

func load_high_score_from_web_storage() -> int:
	var js := """
		(function () {
			try {
				return window.localStorage.getItem("%s") || "0";
			} catch (error) {
				return "0";
			}
		})()
	""" % WEB_STORAGE_KEY
	var stored_score = JavaScriptBridge.eval(js, true)

	if stored_score == null:
		return 0

	return max(0, int(stored_score))
