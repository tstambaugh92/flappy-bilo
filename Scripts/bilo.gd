extends CharacterBody2D

var gravity : float = 981
var jumpForce : float = 600

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	rotation_degrees = rotation_degrees + 90.0 * delta

	if Input.is_action_just_pressed("jump"):
		velocity.y += - jumpForce
		
	move_and_slide()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	get_tree().reload_current_scene()
