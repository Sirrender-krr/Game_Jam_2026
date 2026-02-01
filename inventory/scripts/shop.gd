extends Area2D
class_name ShopInventory

signal toggle_inventory(external_inventory_owner)

@export var inv_data:InventoryData
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var inventory_data

func _ready() -> void:
	inventory_data = inv_data.duplicate()
	animated_sprite_2d.hide()
	animated_sprite_2d.frame = 0

func player_interact() -> void:
	toggle_inventory.emit(self)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body
		animated_sprite_2d.show()
		player.interacting = self

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		animated_sprite_2d.play()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		var player = body
		animated_sprite_2d.hide()
		player.interacting = null
		if get_parent().inventory_interface.visible:
			get_parent().toggle_inventory_interface()
