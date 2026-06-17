extends Node2D

var default_speed : float = 50.0
var speed : float = default_speed
var speed_varience : float = 30.0
var min_speed := default_speed - speed_varience
var max_speed := default_speed + speed_varience


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite : Sprite2D = $Sprite2D
	speed = randf_range(min_speed,max_speed)
	var movement_percentage = inverse_lerp(min_speed,max_speed,speed)
	var local_scale : int = round(lerp(1.0,3.0,movement_percentage))
	sprite.scale = Vector2(local_scale,local_scale)
	
	#Move to the right of the screen, faster clouds on the bottom
	position.x = get_viewport_rect().size.x + sprite.texture.get_width() / 2.0 * local_scale
	position.y = lerp(0.0,get_viewport_rect().size.y,movement_percentage)
	sprite.z_index = round(lerp(-99,-1,movement_percentage))

	$Sprite2D/VisibleOnScreenNotifier2D.rect = sprite.get_rect()
	print_debug("I am a cloud. My z_index is " + str(sprite.z_index) + ". My scale is " + str(local_scale) + ". My y is " + str(position.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= delta * speed


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	print_debug("He's dead Jim")


	
