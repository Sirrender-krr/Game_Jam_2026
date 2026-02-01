extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var slot_datas: Array[SlotData]

func grab_slot_data(index: int) -> SlotData:
	
	var slot_data = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func grab_slot_data_shop(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	if slot_data:
		#slot_datas[index] = null
		inventory_updated.emit(self,'shop')
		return slot_data.duplicate()
	else:
		return null

func grab_slot_data_npc(index: int) -> void:
	
	var slot_data = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return
	else:
		return

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return return_slot_data

func drop_slot_data_shop(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	var return_slot_data: SlotData
	return_slot_data = null
	
	inventory_updated.emit(self,'shop')
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity >0:
		#return grabbed_slot_data.duplicate()
		return grabbed_slot_data
	else:
		return null

func drop_single_slot_data_shop(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data_shop()
	#elif slot_data.can_merge_with(grabbed_slot_data):
		#slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data_shop())
	elif slot_datas:
		grabbed_slot_data.create_single_slot_data_shop()
	
	inventory_updated.emit(self,'shop')
	
	if grabbed_slot_data.quantity >0:
		return grabbed_slot_data
	else:
		return null

#func use_slot_data(index: int) -> void:
	#var slot_data = slot_datas[index]
	#
	#if not slot_data:
		#PlayerManager.empty_hand()
		#return
	#if slot_data.item_data is ItemDataConsumeable:
		#slot_data.quantity -= 1
		#if slot_data.quantity < 1:
			#slot_datas[index] = null
#
	#print(slot_data.item_data.name)
	#PlayerManager.use_slot_data(slot_data)
	#
	#inventory_updated.emit(self)
#
#func use_slot_data_in_hand(index: int) -> void:
	#var slot_data = slot_datas[index]
	#
	#if not slot_data:
		#PlayerManager.empty_hand()
		#return
	#if slot_data.item_data is ItemDataSeed:
		#slot_data.quantity -= 1
		#if slot_data.quantity < 1:
			#slot_datas[index] = null
#
	#print(slot_data.item_data.name)
	#PlayerManager.use_slot_data(slot_data)
	#
	#inventory_updated.emit(self)

func pick_up_slot_data(slot_data: SlotData) -> bool:
	for index in slot_datas.size(): 
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
			
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false

func on_slot_clicked(index: int, button:int) -> void:
	inventory_interact.emit(self,index,button)
