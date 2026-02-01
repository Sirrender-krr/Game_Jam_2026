extends CharacterBody2D
class_name NPC

signal toggle_inventory

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var chat_box: Label = $ChatBox
@onready var texture_rect: TextureRect = $TextureRect


const MASK_02 = preload("res://inventory/resources/item/mask02.tres")
var slot = SlotData.new()

var table_inv:InventoryData


var interacting

const speed = 10.0
var accel = speed

enum dir {left, right, up, down}
enum State {idle, walk}
var direction = dir.down
var state = State.idle

var inventory_interface

var end_left: Vector2
var end_right: Vector2
var left_1: Vector2
var left_2: Vector2
var mid: Vector2
var right_1: Vector2
var right_2: Vector2
var table_spot: Vector2
var leave_dir: Vector2
var first_target:Array
var last_target:Array
var all_target: Array

var current_target_index: int = 0:
	set(value):
		current_target_index = clamp(value,0,2)

func _ready() -> void:
	slot.item_data = MASK_02
	print("name: %s\nbuy: %s\nqty: %s" %[slot.item_data.name,slot.item_data.sell,slot.quantity])
	call_deferred("assign_marker")
	nav2d.navigation_finished.connect(_on_target_reached)
	chat_box.hide()
	texture_rect.hide()
	animated_sprite.material.set_shader_parameter("replace_0",Color(randf(), randf(), randf()))
	animated_sprite.material.set_shader_parameter("replace_1",Color(randf_range(0.4,0.1), randf_range(0.4,0.1), randf_range(0.5,0.4)))

func assign_marker():
	end_left = get_parent().end_left_marker.global_position
	end_right = get_parent().end_right_marker.global_position
	table_spot = get_parent().table_marker.global_position
	left_1 = get_parent().left_marker_1.global_position
	left_2 = get_parent().left_marker_2.global_position
	mid = get_parent().mid_marker.global_position
	right_1 = get_parent().right_marker_1.global_position
	right_2 = get_parent().right_marker_2.global_position
	inventory_interface = get_parent().inventory_interface
	
	first_target = [left_1,left_2,mid,right_1,right_2]
	last_target = [end_left,end_right]
	
	randomize()
	var ran1 = randi_range(0,4)
	var ran2 = randi_range(0,1)
	
	all_target = [first_target[ran1],mid,last_target[ran2]]
	_set_next_target()
	#var ran = randf()
	#if ran >= 0.8:
		#nav2d.target_position = left_1
	#elif ran >= 0.6:
		#nav2d.target_position = left_2
	#elif ran >= 0.4:
		#nav2d.target_position = mid
	#elif ran >= 0.2:
		#nav2d.target_position = right_2
	#elif ran >= 0.0:
		#nav2d.target_position = right_1
	#var ran_leave = randf()
	#if ran_leave >= 0.5:
		#leave_dir = end_left
	#elif ran_leave <0.5:
		#leave_dir = end_right

func _set_next_target():
	nav2d.target_position = all_target[current_target_index]

func _physics_process(delta):
	handle_movement()
	move_and_slide()
	handle_animation()
	navigate(delta)
	interact()
	#manual_navigation() #debug

#
### a temporary function
#func manual_navigation() -> void:
	#if Input.is_action_just_pressed("click"):
		#nav2d.target_position = get_global_mouse_position()

func navigate(delta:float) -> void:
	if nav2d.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity= (global_position.direction_to(next_path_position) * speed)
	position += velocity * delta

func _on_target_reached() -> void:
	velocity = Vector2.ZERO
	if current_target_index >= 2:
		print("done")
		queue_free()
	
	if current_target_index == 0:
		texture_rect.texture = slot.item_data.texture
		texture_rect.show()
	
	if current_target_index == 1:
		await get_tree().create_timer(1).timeout
		buy()
	await get_tree().create_timer(2).timeout
	chat_box.hide()
	texture_rect.hide()
	
	current_target_index += 1
	
	if current_target_index < all_target.size():
		_set_next_target()
	

		

func buy() -> void:
	if table_inv:
		var slot_data = table_inv.slot_datas
		for i in range(slot_data.size()):
			if slot_data[i] and slot_data[i].item_data.name == slot.item_data.name:
				if !random_acceptable_price(slot_data[i].item_data.sell):
					chat_box.show()
					chat_box.text = "What a price, this is tooooooo expensive"
					return
				elif random_acceptable_price(slot_data[i].item_data.sell):
					inventory_interface.gain_money_npc(slot_data[i],slot_data[i].quantity)
					table_inv.grab_slot_data_npc(i)
					chat_box.show()
					chat_box.text = "Good Price. I can buy them all!"
					return

			#else:
		chat_box.show()
		chat_box.text = "Too bad, you did't sell it."
				#print('not found')
				#pass
	else:
		return

func random_acceptable_price(price) -> bool:
	randomize()
	var x = randi_range(0,3)
	var threshold = [1.0,1.1,1.2,1.3]
	print("I expect: ",slot.item_data.suggest_selling * threshold[x])
	return slot.item_data.suggest_selling * threshold[x] >= price

#region movement and animation
func handle_movement() -> void:
	if can_walk():
		if velocity.length() == 0:
			state = State.idle
		else:
			state = State.walk

func handle_animation():
	#movement animation with direction
	if can_walk():
		if accel > speed:
			animated_sprite.speed_scale = 2
		else:
			animated_sprite.speed_scale = 1
	if velocity.x > 0:
		direction = dir.right
		state = State.walk
		animated_sprite.play('walk_right')
	elif velocity.x < 0:
		direction = dir.left
		state = State.walk
		animated_sprite.play('walk_left')
	elif velocity.y < 0:
		direction = dir.up
		state = State.walk
		animated_sprite.play('walk_up')
	elif velocity.y > 0:
		direction = dir.down
		state = State.walk
		animated_sprite.play('walk_down')
	elif velocity.x > 0 and velocity.y != 0:
		direction = dir.right
		state = State.walk
		animated_sprite.play('walk_right')
	elif velocity.x < 0 and velocity.y != 0:
		direction = dir.left
		state = State.walk
		animated_sprite.play('walk_left')
	#idle animation with direction
	elif velocity == Vector2.ZERO and direction == dir.right:
		animated_sprite.play('idle_right')
		state = State.idle
	elif velocity == Vector2.ZERO and direction == dir.left:
		animated_sprite.play('idle_left')
		state = State.idle
	elif velocity == Vector2.ZERO and direction == dir.up:
		animated_sprite.play('idle_up')
		state = State.idle
	elif velocity == Vector2.ZERO and direction == dir.down:
		animated_sprite.play('idle_down')
		state = State.idle
	
func can_walk() -> bool:
	return state == State.idle or state == State.walk

func can_run() -> bool:
	return state == State.walk

func can_interact() -> bool:
	return state == State.idle or state == State.walk

func interact() -> void:
	if can_interact() and Input.is_action_just_pressed("interact")\
	 and interacting:
		interacting.player_interact()
	else:
		pass
#endregion
