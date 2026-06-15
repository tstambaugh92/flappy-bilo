extends Node2D

const CLOUD_IMGS := [
	preload("res://Assets/images/Fat Cloud.png"),
	preload("res://Assets/images/Judgemental Cloud.png")
]

var cloud_template : PackedScene = preload("res://Scenes/single_cloud.tscn")
@onready var timer: Timer = $Timer
@onready var original_wait: float = timer.wait_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_timer_timeout()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	spawn_cloud()
	timer.wait_time = original_wait + randf_range(-1,1)

func spawn_cloud() -> void:
	var cloud_texture : Texture2D = CLOUD_IMGS.pick_random()
	var new_cloud := cloud_template.instantiate()
	var sprite := new_cloud.get_node("Sprite2D") as Sprite2D
	sprite.texture = cloud_texture
	add_child(new_cloud)
	pass
