extends PanelContainer

const Slot = preload("res://inventory/scenes/slot.tscn")
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid


func set_inventory_data(inventory_data: InventoryData, is_shop=null) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data, is_shop)
	
func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data:InventoryData, is_shop=null) -> void:
	for child in item_grid.get_children():
		child.queue_free()

	var slots = inventory_data.slot_datas
	##When coin reach 0 it will disappear
	for i in range(slots.size()):
		if slots[i]:
			if slots[i].item_data is ItemDataCoin:
				if slots[i].quantity < 1:
					slots[i] = null
					continue

	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data,is_shop)
