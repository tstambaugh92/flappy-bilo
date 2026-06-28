extends Node2D

@onready var the_hero : Sprite2D = $Bilo
@onready var this_is_bilo : AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	position_frame()
	this_is_bilo.play()

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
#	position_bilo()
#	position_this_is_bilo()
	position_item(the_hero,.3,Vector2(.1,.1))
	#I had separate functions for different items. I thought I'd be clever and combine them
	#I ended up with this abortion of a function call
	#The gist is, move 10% + 80% of the heros size to the right and paste the animation there
	#80% is chosen by experiment with what looks best
	position_item(this_is_bilo,.3,Vector2(.1+(the_hero.get_rect().size.x * the_hero.scale.x * .8) / get_viewport_rect().size.x, .1))

func position_item(item : Node2D, x_percent : float, pos : Vector2):
	var viewport_size : Vector2 = get_viewport_rect().size
	var item_scale : float = 0.0
	var item_size: Vector2 = Vector2()
	if item is Sprite2D:
		item_size = item.get_rect().size
		item_scale = (viewport_size.x * x_percent) / item_size.x
	elif item is AnimatedSprite2D:
		item_size = item.sprite_frames.get_frame_texture(item.animation,item.frame).get_size()
		item_scale = (viewport_size.x * x_percent) / item_size.x
		
	
	item.scale = Vector2(item_scale,item_scale)
	item.position = Vector2(
		viewport_size.x * pos.x + item_size.x * item_scale / 2.0,
		viewport_size.y * pos.y + item_size.y * item_scale / 2.0
	)
	print_debug("I am item at " + str(item.position.x) + " , " + str(item.position.y))
