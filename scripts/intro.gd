extends Control

@onready var button: Button = $Button
@onready var animated_sprite_2d: AnimatedSprite2D = $Button/AnimatedSprite2D
@onready var player: Player = $Player
#var WORLD = preload("res://scenes/world.tscn")

func _ready() -> void:
	animated_sprite_2d.frame= 0


func _on_button_pressed() -> void:
	var world = load("res://scenes/world.tscn")
	animated_sprite_2d.play()
	
	
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(world)
