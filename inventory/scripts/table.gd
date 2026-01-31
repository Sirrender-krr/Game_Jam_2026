extends StaticBody2D

signal toggle_inventory(external_inventory_owner)
#signal chest_broke(external_inventory_owner, pos)

@export var inv_data:InventoryData

var inventory_data: InventoryData

#var PickUp = preload("res://inventory/Pickups/pickup.tscn")


func _ready() -> void:
	inventory_data = inv_data.duplicate()



func player_interact() -> void:
	toggle_inventory.emit(self)



func _on_area_2d_body_entered(body: Player) -> void:
	var player = body
	toggle_inventory.emit(self)
	player.interacting = self


func _on_area_2d_body_exited(body: Player) -> void:
	var player = body
	player.interacting = null
	chest_close()


func chest_close() -> void:
	get_parent().inventory_interface.hide()
