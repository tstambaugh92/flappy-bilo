extends Node2D

const LOGO_ANIMATION := "logo"
const TARGET_WIDTH_RATIO : float = 0.5
const TOP_RATIO : float = 0.1

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var logo_root : Node2D = $"Logo Root"

var title_screen : PackedScene = preload("res://Scenes/title.tscn")
var final_logo_bounds := Rect2()
var waiting : bool = false
var playing : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web"):
		waiting = true
	if waiting:
		logo_root.visible = false

func start_intro() -> void:
	while not is_inside_tree():
		await tree_entered

	var bg_music : AudioStreamPlayer2D = get_node_or_null("/root/Music") as AudioStreamPlayer2D
	while bg_music == null:
		await get_tree().process_frame
		bg_music = get_node_or_null("/root/Music") as AudioStreamPlayer2D
	#The above shit is due to, if i hit space as soon as the game starts loading
	#it tries to pause the bg music before it exists. 
	bg_music.stream_paused = true
	final_logo_bounds = calculate_final_logo_bounds()
	position_logo()
	get_viewport().size_changed.connect(position_logo)
	animation_player.play(LOGO_ANIMATION)

func position_logo() -> void:
	#The goal here is to land this fucking thing in the same
	#position it needs to be at for title.tscn
	#I just dragged, dropped, and played with the animation player.
	#Perhaps with more planning this can be cleaner.
	if final_logo_bounds.size.x == 0:
		return

	var viewport_size := get_viewport_rect().size
	var scale_factor := viewport_size.x * TARGET_WIDTH_RATIO / final_logo_bounds.size.x
	logo_root.scale = Vector2.ONE * scale_factor

	logo_root.position = Vector2(
		viewport_size.x * 0.5 - final_logo_bounds.get_center().x * scale_factor,
		viewport_size.y * TOP_RATIO - final_logo_bounds.position.y * scale_factor
	)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		position_logo()

	if Input.is_action_just_pressed("jump"):
		if waiting:
			waiting = false
		else:
			_on_animation_player_animation_finished("Skip this shit")

	if not playing and not waiting:
		playing = true
		start_intro()
		waiting = false
		$"Web Text".visible = false
		logo_root.visible = true

func calculate_final_logo_bounds() -> Rect2:
	animation_player.play(LOGO_ANIMATION)
	animation_player.seek(animation_player.current_animation_length, true)
	var bounds := calculate_logo_bounds()
	animation_player.seek(0.0, true)
	animation_player.stop()
	return bounds


func calculate_logo_size() -> Vector2:
	return calculate_logo_bounds().size


func calculate_logo_bounds() -> Rect2:
	#This should calculate the size of the Bilo logo...
	#There surely must be a better way of calculating the virtual size of
	#a node. Why can't "Logo Root" have a size property? There is probably
	#a way to do that, but I think this crap is fine for now.
	var bounds := Rect2()
	var first : bool = true
	for child in logo_root.get_children():
		if child is Sprite2D and child.texture:
			var rect : Rect2 = child.get_rect()
			var points := [
				rect.position,
				rect.position + Vector2(rect.size.x, 0),
				rect.position + Vector2(0, rect.size.y),
				rect.position + rect.size,
			]

			for point in points:
				#The transform should account for rotation and scaling
				#because the size and position calculations above are pre-transform,
				#which is confusing. Maybe I'm going about this the wrong way,
				#or maybe Im just a baby
				var transformed_point = child.transform * point
				if first:
					bounds = Rect2(transformed_point, Vector2.ZERO)
					first = false
				else:
					#this function seems to do some magic stretching for me.
					#really neat.... so why isnt it just a property of the parent 🙄
					#Will emoji play nice with the game engine? About to find out.
					bounds = bounds.expand(transformed_point)

	return bounds


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(title_screen)
