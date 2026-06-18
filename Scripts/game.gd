extends Node2D

var water_bear_scene := preload("res://Scenes/water_bear.tscn")
var score_width : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pan_con : PanelContainer = $PanelContainer
	score_width = pan_con.size.x
	resize_score_box()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	 
func resize_score_box() -> void:
	var pan_con : PanelContainer = $PanelContainer
	#don't fill more than half the screen
	var ratio : float = pan_con.size.x / get_viewport_rect().size.x
	if ratio > .5:
		pan_con.set_size(Vector2(get_viewport_rect().size.x / 2,pan_con.size.y))
	else:
		pan_con.set_size(Vector2(score_width,pan_con.size.y))
	
	pan_con.position[0] = get_viewport_rect().size.x - pan_con.size.x
	pan_con.z_index = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Score.printed_score != Score.last_score:
		$PanelContainer/MarginContainer/Label.text = "Score: " + str(Score.last_score)
		Score.printed_score = Score.last_score
	
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_viewport_size_changed() -> void:
	resize_score_box()


func _on_timer_timeout() -> void:
	var water_bear := water_bear_scene.instantiate()
	water_bear.position = Vector2(
		get_viewport_rect().size.x + 64,
		get_viewport_rect().size.y / 2 + randf_range(-200,200)
	)
	add_child(water_bear)
	var t := $"Timer"
	t.start()
