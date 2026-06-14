extends Node2D

var speed := 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite : Sprite2D = $Sprite2D
	position.x = get_viewport_rect().size.x + sprite.texture.get_width() / 2.0
	position.y = get_viewport_rect().size.y / 2.0
	print("Cloud spawned")
	$VisibleOnScreenNotifier2D.rect = sprite.get_rect()
	speed += randi_range(-10,10)
	position.y += randf_range(-(get_viewport_rect().size.y / 2),(get_viewport_rect().size.y / 2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= delta * speed


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	print("He's dead Jim")
	
