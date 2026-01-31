extends Area2D
class_name ShopInventory

signal toggle_inventory(external_inventory_owner)

@export var inv_data:InventoryData

var inventory_data

func _ready() -> void:
	inventory_data = inv_data.duplicate()

func player_interact() -> void:
	toggle_inventory.emit(self)

func _on_body_entered(body: Node2D) -> void:
	var player = body
	player.interacting = self


func _on_body_exited(body: Node2D) -> void:
	var player = body
	player.interacting = null
	if get_parent().inventory_interface.visible:
		get_parent().toggle_inventory_interface()
