extends Node

var high_score : int = 0
var last_score : int = 0
var printed_score : int = 0
# Called when the node enters the scene tree for the first time.

var PATH := "user://score.save"

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_high_score() -> void:
	var file := FileAccess.open(PATH,FileAccess.WRITE)
	file.store_32(high_score)

func load_high_score() -> void:
	if high_score == 0:
		var file := FileAccess.open(PATH,FileAccess.READ)
		if file == null:
			print_debug("No Save Found")
			return
		high_score = file.get_32()
