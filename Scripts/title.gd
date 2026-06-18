extends Node2D

var actual_game : PackedScene = preload("res://Scenes/game.tscn")
var score_width : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite : Sprite2D = $BiloLogo
	position_title_sprite(sprite)
	score_width = $PanelContainer.size.x
	if Score.high_score == 0:
		Score.load_high_score()
	$PanelContainer/MarginContainer/Label.text = "High Score: " + str(Score.high_score)
	resize_score_box()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	#I dont like mixing code signals with godot signals but I don't know how to 
	#access view_port signals in the godot editor lol

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if Input.is_action_just_pressed("jump"):
		get_tree().change_scene_to_packed(actual_game)


func position_title_sprite(sprite: Sprite2D) -> void:
	var viewport_size := get_viewport_rect().size
	var texture_size := sprite.texture.get_size()

	var target_width := viewport_size.x * 0.5
	var scale_factor := target_width / texture_size.x
	var scaled_height := texture_size.y * scale_factor

	sprite.scale = Vector2.ONE * scale_factor

	sprite.position = Vector2(
		viewport_size.x * 0.5,
		viewport_size.y * 0.1 + scaled_height / 2.0
	)

func _on_viewport_size_changed() -> void:
	var sprite : Sprite2D = $BiloLogo
	position_title_sprite(sprite)
	resize_score_box()


func resize_score_box() -> void:
	var pan_con : PanelContainer = $PanelContainer
	#don't fill more than half the screen
	var ratio : float = pan_con.size.x / get_viewport_rect().size.x
	if ratio > .5:
		pan_con.set_size(Vector2(get_viewport_rect().size.x / 2,pan_con.size.y))
	else:
		pan_con.set_size(Vector2(score_width , pan_con.size.y))
	
	pan_con.position[0] = get_viewport_rect().size.x - pan_con.size.x
	pan_con.z_index = 1