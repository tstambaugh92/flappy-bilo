extends Node2D

var speed := 100.0

func _ready() -> void:
	var screen_height: float = get_viewport_rect().size.y
	var lower_body: AnimatedSprite2D = $"Lower Bear/WaterBearBody"
	var upper_body: AnimatedSprite2D = $"Upper Bear/WaterBearBody"
	var lower_body_height: float = get_sprite_height(lower_body)
	var upper_body_height: float = get_sprite_height(upper_body)
	var upper_collider : CollisionShape2D = $"Upper Bear/CollisionShape2D"
	var lower_collider : CollisionShape2D = $"Lower Bear/CollisionShape2D"
	#the upper body is the lower body rotated 180 degrees

	var lower_distance: float = screen_height - (lower_body.global_position.y + lower_body_height / 2.0)
	var upper_distance: float = upper_body.global_position.y - upper_body_height / 2.0

	add_body_segments(lower_body, lower_distance, lower_body_height,lower_collider)
	add_body_segments(upper_body, upper_distance, upper_body_height,upper_collider)


func get_sprite_height(sprite: AnimatedSprite2D) -> float:
	var texture: Texture2D = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)
	return texture.get_height() * absf(sprite.scale.y)


func add_body_segments(
	body: AnimatedSprite2D, #uppder or lower bear
	distance: float,
	segment_height: float,
	collider : CollisionShape2D
) -> void:
	var segment_count: int = ceili(maxf(0.0, distance) / segment_height)
	collider.shape = collider.shape.duplicate()
	var rect := collider.shape as RectangleShape2D
	

	#extend the collider to the first body segment
	rect.size.y += segment_height
	collider.position.y += segment_height/2

	for i in range(1, segment_count + 1):
		#add body segments to cover the screen vertically and extend the collider
		var segment: AnimatedSprite2D = body.duplicate() as AnimatedSprite2D
		segment.position.y += segment_height * i
		body.get_parent().add_child(segment)
		rect.size.y += segment_height
		collider.position.y += segment_height/2
		
		
		


func _physics_process(delta: float) -> void:
	position.x -= speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_lower_bear_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()
