extends Resource
class_name SlotData

#@export var MAX_STACK_SIZE: int = 10

@export var item_data: ItemData
@export var quantity: int = 1:
	set(value):
		quantity = clamp(value,0,item_data.MAX_STACK_SIZE)
		if quantity > 1 and not item_data.stackable:
			quantity = 1

func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data\
	and item_data.stackable\
	and quantity <= item_data.MAX_STACK_SIZE

func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data\
	and item_data.stackable\
	and quantity + other_slot_data.quantity <= item_data.MAX_STACK_SIZE

func fully_merge_with(slot_data: SlotData) -> void:
	var other_slot_data = slot_data.duplicate()
	quantity += other_slot_data.quantity

func create_single_slot_data() -> SlotData:
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data

func create_single_slot_data_shop() -> SlotData:
	quantity -= 1
	return null
