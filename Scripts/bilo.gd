extends CharacterBody2D


var gravity : float = 981
var jumpForce : float = 350
var score : int = 0
var rotation_degrees_per_sec : float = 0 #deg/s
const rotation_impulse : float = 60.0 #deg/s - The amount added by a jump
const rotation_slow : float = rotation_impulse / 0.7 #degrees/s^2, divided by X seconds to decay over that time
#These numbers were all just played with until one set felt good.

@onready var animation : AnimatedSprite2D = $"BilosAnimation"
@onready var death_sound : AudioStreamPlayer2D = $"DeathSound"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if rotation_degrees_per_sec > 0.0:
		rotation_degrees_per_sec = move_toward(rotation_degrees_per_sec,0.0,rotation_slow*delta)

	if Input.is_action_just_pressed("jump"):
		velocity.y = - jumpForce
		if not animation.is_playing():
			animation.play("jump")
			if rotation_degrees_per_sec > 360.0:
				rotation_degrees_per_sec = 360.0
		rotation_degrees_per_sec += rotation_impulse
	rotation_degrees += rotation_degrees_per_sec * delta #we're in radians, I guess
			
		
	move_and_slide()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#die if you fall off the screen
	print_debug("I should be dying")
	die()


func _on_area_2d_area_entered(area: Area2D) -> void:
	print_debug("Touched: ", area.name, " kill? ", area.is_in_group("kill"))
	if area.is_in_group("kill"):
		die()
	elif area.is_in_group("score"):
		score += 1
		Score.last_score = score
		print_debug("Score is " + str(score))

func die() -> void:
	var bg_music : AudioStreamPlayer2D = get_node("/root/Music")
	get_tree().paused = true
	bg_music.stream_paused = true
	death_sound.process_mode = Node.PROCESS_MODE_ALWAYS #play music when the game is paused
	death_sound.play()
	animation.process_mode = Node.PROCESS_MODE_ALWAYS
	animation.play("die")
	await death_sound.finished
	await animation.animation_finished
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().paused = false
	bg_music.stream_paused = false
	Score.last_score = score
	if Score.last_score > Score.high_score:
		Score.high_score = Score.last_score
		Score.save_high_score()
	var err := get_tree().change_scene_to_file("res://Scenes/title.tscn")
	print_debug("Error: " + error_string(err))
