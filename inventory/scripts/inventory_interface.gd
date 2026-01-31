extends Control

signal drop_slot_data(slot_data: SlotData)

var grabbed_slot_data: SlotData
var external_inventory_owner
var player_inventory_data: InventoryData
var coins:
	set(value):
		coins = value
		print(coins)
@export var COIN: SlotData


@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grab_slot: PanelContainer = $GrabSlot
@onready var external_inventory: PanelContainer = $ExternalInventory



func _physics_process(_delta: float) -> void:
	if grab_slot.visible:
		grab_slot.global_position = get_global_mouse_position() + Vector2(1,1)
		grab_slot.scale = Vector2(0.8,0.8)
		

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
	player_inventory_data = inventory_data

func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	#if external_inventory_owner is ShopInventory:
		#var inventory_data = external_inventory_owner.inventory_data
		#inventory_data.inventory_interact.connect(on_inventory_interact_shop)
		#external_inventory.set_inventory_data(inventory_data)
		#pass
	#else:
		#var inventory_data = external_inventory_owner.inventory_data
	#
		#inventory_data.inventory_interact.connect(on_inventory_interact)
		#external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

##a function to do inside Inventory Tab
func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	match [grabbed_slot_data, button]:
		[null,MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_,MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data,index)
		[null,MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_,MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data,index)
	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grab_slot.show()
		grab_slot.set_slot_data(grabbed_slot_data)
	else:
		grab_slot.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton\
	and event.is_pressed()\
	and grabbed_slot_data:
		#if grabbed_slot_data.item_data is ItemDataChest:
			#var mouse_pos = get_parent().get_parent().position_in_radius()
			#if PlacingManager.is_tile_occupied(mouse_pos):
				#pass
			#else:
				#PlacingManager.attemp_placement(mouse_pos)
				#match event.button_index:
					#MOUSE_BUTTON_LEFT:
						#drop_slot_data.emit(grabbed_slot_data)
						#grabbed_slot_data = null
					#MOUSE_BUTTON_RIGHT:
						#drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
						#if grabbed_slot_data.quantity < 1:
							#grabbed_slot_data = null
				#update_grabbed_slot()
		#else:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		update_grabbed_slot()

func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()

#region shop
###a function to do inside Shop Inventory Tab
#func on_inventory_interact_shop(inventory_data: InventoryData, index: int, button: int) -> void:
	#match [grabbed_slot_data, button]:
		#[null,MOUSE_BUTTON_LEFT]:
			###buy
			#if inventory_data.slot_datas[index]:
				#if can_loss_money(inventory_data.slot_datas[index]):
					#grabbed_slot_data = inventory_data.grab_slot_data_shop(index)
					#loss_money(grabbed_slot_data,grabbed_slot_data.quantity)
		#[_,MOUSE_BUTTON_LEFT]:
			###continue buying
			#if inventory_data.slot_datas[index]:
				#if grabbed_slot_data.item_data == inventory_data.slot_datas[index].item_data:
					#if can_loss_money(inventory_data.slot_datas[index]):
						#grabbed_slot_data.quantity += inventory_data.slot_datas[index].quantity
						#loss_money(inventory_data.slot_datas[index],inventory_data.slot_datas[index].quantity)
				###sell
				#else:
					#gain_money(grabbed_slot_data,grabbed_slot_data.quantity)
					#grabbed_slot_data = inventory_data.drop_slot_data_shop(grabbed_slot_data,index)
			###sell
			#else:
				#gain_money(grabbed_slot_data,grabbed_slot_data.quantity)
				#grabbed_slot_data = inventory_data.drop_slot_data_shop(grabbed_slot_data,index)
		#[null,MOUSE_BUTTON_RIGHT]:
			#pass
		#[_,MOUSE_BUTTON_RIGHT]:
			###sell a piece
			#gain_money(grabbed_slot_data, 1)
			#grabbed_slot_data = inventory_data.drop_single_slot_data_shop(grabbed_slot_data,index)
	#update_grabbed_slot()
##
##func gain_money(slot_data:SlotData,qty:int) -> void:
	##var inventory = player_inventory_data as InventoryData
	##var coin = COIN.duplicate() as SlotData
	##coin.quantity = 0
	##var slots = inventory.slot_datas
	###for i in slots:
		###if i:
			###if i.item_data is ItemDataCoin:
				###i.quantity += slot_data.item_data.sell * qty
				###coins = i.quantity
				###inventory.inventory_updated.emit(inventory)
				###return
##
	##for index in range(slots.size()):
		##if !slots[index]:
			##coin.quantity = slot_data.item_data.sell * qty
			##slots[index] = coin
			##inventory.inventory_updated.emit(inventory)
			##return
##
##func can_loss_money(slot_data:SlotData):
	##var inventory = player_inventory_data as InventoryData
	##var slots = inventory.slot_datas
	##var item_price = slot_data.item_data.buy
	##var item_qty = slot_data.quantity
	##var sum = item_price * item_qty
	##
	#print(slot_data.item_data.name,": ",slot_data.quantity)
	#for i in slots:
		#if i:
			#if i.item_data is ItemDataCoin and i.quantity < sum:
				#return false
			#if i.item_data is ItemDataCoin and i.quantity >= sum:
				#if grabbed_slot_data:
					#if grabbed_slot_data.item_data.MAX_STACK_SIZE > item_qty:
						#return true
					#else:
						#return false
				#return true
			#else:
				#print("don't have money")
				#return false
		#elif !i:
			#print("don't have money 2")
			#return false
		#else:
			#print("don't have money 3")
			##return false
	#for i in range(slots.size()):
		#if !slots[i]:
			#return false
		#
		#
#
#func loss_money(slot_data:SlotData,qty:int) -> void:
	#var inventory = player_inventory_data as InventoryData
	#var slots = inventory.slot_datas
	#for i in slots:
		#if i:
			#if i.item_data is ItemDataCoin:
				#if i.quantity >= slot_data.item_data.buy * qty:
					#i.quantity -= slot_data.item_data.buy * qty
					#coins = i.quantity
					#inventory.inventory_updated.emit(inventory)
					#return
		##else:
			##for index in range(slots.size()):
				##if !slots[index]:
					##return
#endregion
