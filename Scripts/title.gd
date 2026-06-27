extends Node2D

var actual_game : PackedScene = preload("res://Scenes/game.tscn")
var score_width : int = 0
const BOTTOM_RATIO : float = .9
#Its at this point where I need to add more references that
#I am starting to see why I should probably accept UUIDs instead of paths lol
@onready var credits_text : Label = $"Credits"
@onready var start_text : Label = $"Start Text"
@onready var logo_sprite : Sprite2D = $"BiloLogo"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bg_music : AudioStreamPlayer2D = $"/root/Music"
	if not bg_music.playing:
		bg_music.play()
	position_title_screen()
	score_width = $PanelContainer.size.x
	if Score.high_score == 0:
		Score.load_high_score()
	$"PanelContainer/MarginContainer/High Score Text".text = "High Score: " + str(Score.high_score)
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


func position_title_screen() -> void:
	#Center the logo vertically and 10% from the top
	#Start text right below it by 10px
	#Credits text 10% from the bottom
	#I'm not sure there if theres the equal of divs
	#and CSS here, but I should probably be using it.
	var viewport_size := get_viewport_rect().size
	var texture_size := logo_sprite.texture.get_size()

	var target_width := viewport_size.x * 0.5
	var scale_factor := target_width / texture_size.x
	var scaled_height := texture_size.y * scale_factor

	logo_sprite.scale = Vector2.ONE * scale_factor

	logo_sprite.position = Vector2(
		viewport_size.x * 0.5,
		viewport_size.y * 0.1 + scaled_height / 2.0
	)

	start_text.position = Vector2(
		(viewport_size.x - start_text.size.x) * .5,
		logo_sprite.position.y + scaled_height * .5 + 10
	)

	credits_text.position = Vector2(
		(viewport_size.x - credits_text.size.x) * .5,
		viewport_size.y * BOTTOM_RATIO
	)

func _on_viewport_size_changed() -> void:
	position_title_screen()
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


func _on_timer_timeout() -> void:
	#Flashing text. Timer at .66 seconds works well with the music
	start_text.visible = ! start_text.visible
