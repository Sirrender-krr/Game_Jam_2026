extends Node2D


@export var ground_tilemap_layer: TileMapLayer

signal inv_show(inv_visible: bool)

@onready var player: Player = $Player
@onready var inventory_interface: Control = $CanvasLayer/InventoryInterface
#@onready var hot_bar_inventory: PanelContainer = $CanvasLayer/HotBarInventory

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	#inventory_interface.drop_slot_data.connect(_on_inventory_interface_drop_slot_data)
	#hot_bar_inventory.set_inventory_data(player.inventory_data)
	connect_external_inventory_signal()


func connect_external_inventory_signal() -> void:
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)
		#node.chest_broke.connect(_on_chest_broke)
		#
	#for node in get_tree().get_nodes_in_group("shop_house"):
		#node.toggle_inventory.connect(toggle_inventory_interface)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		#hot_bar_inventory.hide()
		inv_show.emit(inventory_interface.visible)
		
	else:
		#hot_bar_inventory.show()
		inv_show.emit(inventory_interface.visible)
	
	if external_inventory_owner:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

##items in chest drop
#func _on_chest_broke(external_inventory_owner,pos) -> void:
	#var chest_inv = external_inventory_owner.inventory_data
	#var rep_count = 0
	#for item in chest_inv.slot_datas:
		#var slot = PickUp.instantiate().duplicate()
		#if item:
			#slot.slot_data = item
			#var variant = pow(-1.0,rep_count)*rep_count * 3 #-1^n*n*3
			#slot.global_position = Vector2((pos.x + variant), pos.y+5)
			#add_child(slot)
			##print(slot.global_position)
			#rep_count+=1
		#if !item:
			#continue
		#

## item drop on ground
#func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	#var pick_up = PickUp.instantiate() as Node2D
	#pick_up.slot_data = slot_data.duplicate()
	#
	#if pick_up.slot_data.item_data is ItemDataChest:
		#var chest = Chest.instantiate()
		#chest.global_position = chest_place_on_grid()
		#add_child(chest)
		#connect_external_inventory_signal()
	#elif pick_up.slot_data.item_data is ItemDataCoin:
		#var coin_purse = CoinPurse.instantiate() as Node2D
		#coin_purse.slot_data = slot_data.duplicate()
		#coin_purse.global_position = position_in_radius()
		#add_child(coin_purse)
	#else:
		#var rep = 0
		#var qty = slot_data.quantity
		#for item in qty:
			#pick_up = PickUp.instantiate() as Node2D
			#pick_up.slot_data = slot_data.duplicate()
			#pick_up.slot_data.quantity = 1
			#var variant = pow(-1.0, rep) * rep * 1.5
			#pick_up.global_position = position_in_radius()
			#var pos = pick_up.global_position
			#pick_up.global_position = Vector2((pos.x + variant), pos.y)
			#add_child(pick_up)
			#rep +=1
		#pick_up.position = position_in_radius()
		#add_child(pick_up)
#
##calculate drop position
#func position_in_radius() -> Vector2:
	#var radius = 20
	#var mouse_pos = get_global_mouse_position()
	#var direction_vector = mouse_pos - player.global_position
	#var normal_dir = direction_vector.normalized()
	#var return_position = player.global_position + (normal_dir * radius)
	#
	#var dis = normal_dir * radius
	#var distance = dis.length()
	#
	#if direction_vector.length() < distance:
		#return mouse_pos
	#else:
		#return return_position
#
#
#func chest_place_on_grid() -> Vector2:
	#var mouse_position = ground_tilemap_layer.get_local_mouse_position()
	#var cell_position = ground_tilemap_layer.local_to_map(mouse_position)
	#var cell_source_id = ground_tilemap_layer.get_cell_source_id(cell_position)
	#var local_cell_position = ground_tilemap_layer.map_to_local(cell_position)
	#
	#var player_on_grid = return_in_grid(player.global_position)
	#
	#var radius = 20
	#var direction_vector = local_cell_position - player_on_grid
	#var normal_dir = direction_vector.normalized()
	#var return_position = player_on_grid + (normal_dir * radius)
	#var dis = normal_dir * radius
	#var distance = dis.length()
	#
	#if direction_vector.length() <= distance and cell_source_id != -1:
		#return local_cell_position
	#elif direction_vector.length() > distance and cell_source_id != -1:
		#var return_on_grid = return_in_grid(return_position)
		#return return_on_grid
	#else:
		#return player_on_grid
#
#func return_in_grid(location: Vector2) -> Vector2:
	#var cell_position = ground_tilemap_layer.local_to_map(location)
	#var local_cell_position = ground_tilemap_layer.map_to_local(cell_position)
	#return local_cell_position
