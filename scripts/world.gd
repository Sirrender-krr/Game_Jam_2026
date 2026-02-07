extends Node2D


#@export var ground_tilemap_layer: TileMapLayer
@export_range(10, 100, 10, "suffix:%") var npc_spawn_chance: int = 10

signal inv_show(inv_visible: bool)
@onready var left_marker_1: Marker2D = $Markers/LeftMarker1
@onready var left_marker_2: Marker2D = $Markers/LeftMarker2
@onready var mid_marker: Marker2D = $Markers/MidMarker
@onready var right_marker_2: Marker2D = $Markers/RightMarker2
@onready var right_marker_1: Marker2D = $Markers/RightMarker1
@onready var table_marker: Marker2D = $Markers/TableMarker
@onready var end_right_marker: Marker2D = $Markers/EndRightMarker
@onready var end_left_marker: Marker2D = $Markers/EndLeftMarker
@onready var color_rect: ColorRect = $ColorRect
@onready var npc_spawn_timer: Timer = $NpcSpawnTimer
@onready var tab_animation: AnimatedSprite2D = $CanvasLayer/GUI/Tab_animation
@onready var e_animation: AnimatedSprite2D = $CanvasLayer/GUI/E_animation
@onready var shift_animation: AnimatedSprite2D = $CanvasLayer/GUI/ShiftAnimation
@onready var label: Label = $Player/Label
@onready var mouse_animation_left: AnimatedSprite2D = $CanvasLayer/GUI/MouseAnimationLeft
@onready var mouse_animation_right: AnimatedSprite2D = $CanvasLayer/GUI/MouseAnimationRight
@onready var resume_button: Button = $CanvasLayer/GUI/resume_button
@onready var resume_animation: AnimatedSprite2D = $CanvasLayer/GUI/resume_button/resume_animation
@onready var resume_label: Label = $CanvasLayer/GUI/resume_button/resume_Label
@onready var clock: Label = $clock
@onready var day_night_cycle: CanvasModulate = $DayNightCycle
@onready var end_day_anim: AnimatedSprite2D = $CanvasLayer/GUI/EndDay/EndDayAnim
@onready var table: table = $table


const NPC = preload("res://scenes/npc/npc.tscn")

var current_day:int=0
var hour: int

@onready var player: Player = $Player
@onready var inventory_interface: Control = $CanvasLayer/InventoryInterface
#@onready var hot_bar_inventory: PanelContainer = $CanvasLayer/HotBarInventory

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	day_night_cycle.day_end.connect(_on_day_end)
	connect_external_inventory_signal()
	color_rect.show()
	label.hide()
	tab_animation.frame = 0
	e_animation.frame = 0
	shift_animation.frame = 0
	mouse_animation_left.frame = 0
	mouse_animation_right.frame =0
	day_night_cycle.time_tick.connect(_on_time_tick)
	
	#after this will be slow
	await get_tree().create_timer(2).timeout
	label.show()
	label.text = "I have to buy some masks"
	await get_tree().create_timer(2).timeout
	label.hide()
	await get_tree(). create_timer(10).timeout
	spawn_npc()

func _on_time_tick(day:int,hour:int,minute:int) -> void:
	clock.text = str("Day: %d\nTime: %02d:%02d") %[day,hour,minute]
	current_day = day

func spawn_npc() -> void:
	var npc = NPC.instantiate()
	randomize()
	var spawn_pos = [end_left_marker.global_position,end_right_marker.global_position]
	
	npc.global_position = spawn_pos[randi_range(0,1)]
	add_child(npc)
	npc_spawn_timer.wait_time = randi_range(1,10)
	npc_spawn_timer.start()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
			tab_animation.play()
	if Input.is_action_just_pressed("interact"):
		e_animation.play()
	if Input.is_action_just_pressed("run"):
		shift_animation.play()
	elif Input.is_action_just_released("run"):
		shift_animation.play_backwards()
	if Input.is_action_just_pressed("click"):
		mouse_animation_left.flip_h = true
		mouse_animation_left.play()
	elif Input.is_action_just_released("click"):
		mouse_animation_left.flip_h = true
		mouse_animation_left.play_backwards()
	if Input.is_action_just_pressed("right_click"):
		print('click')
		mouse_animation_right.play()
	elif Input.is_action_just_released("right_click"):
		mouse_animation_right.play_backwards()


func connect_external_inventory_signal() -> void:
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)
		#node.chest_broke.connect(_on_chest_broke)
		#
	for node in get_tree().get_nodes_in_group("shop_house"):
		node.toggle_inventory.connect(toggle_inventory_interface)

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


func _on_npc_spawn_timer_timeout() -> void:
	var chance = randi_range(1,100)
	if hour <= 19:
		if chance <= npc_spawn_chance:
			print("npc in")
			spawn_npc()
		else:
			print('npc not spawn')
			npc_spawn_timer.start()
	elif hour > 19:
		if chance <= npc_spawn_chance/2:
			spawn_npc()
		else:
			npc_spawn_timer.start()

func _on_end_day_pressed() -> void:
	end_day_anim.play("default")
	_on_day_end()

func _on_day_end() -> void:
	var day_end = load("res://scenes/day_end_summary.tscn")
	GameManager.day = current_day
	GameManager.player_inventory = player.inventory_data
	GameManager.table_inventory = table.inventory_data
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = true
	get_tree().change_scene_to_packed(day_end)
