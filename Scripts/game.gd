extends Node2D

var water_bear_scene := preload("res://Scenes/water_bear.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

		


func _on_timer_timeout() -> void:
	var water_bear := water_bear_scene.instantiate()
	water_bear.position = Vector2(
		get_viewport_rect().size.x + 64,
		get_viewport_rect().size.y / 2 + randf_range(-200,200)
	)
	add_child(water_bear)
	var t := $"Timer"
	t.start()
