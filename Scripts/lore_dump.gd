extends Node2D

@onready var animator : AnimationPlayer = $"AnimationPlayer"
@onready var stage : int = 1
const STAGE_SIZE: Vector2 = Vector2(640, 640)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	position_frame()
	play_animation()

func play_animation() -> void:
	animator.play("intro_lore")
	await  animator.animation_finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_viewport_size_changed() ->void:
	position_frame()


func position_frame() -> void:
	pass
