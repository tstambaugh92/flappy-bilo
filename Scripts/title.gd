extends Node2D

var actual_game : PackedScene = preload("res://Scenes/game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite : Sprite2D = $BiloLogo
	position_title_sprite(sprite)
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
