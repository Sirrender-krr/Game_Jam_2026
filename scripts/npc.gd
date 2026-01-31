extends CharacterBody2D
class_name NPC

signal toggle_inventory

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav2d: NavigationAgent2D = $NavigationAgent2D

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

var end_left: Vector2
var end_right: Vector2
var left_1: Vector2
var left_2: Vector2
var mid: Vector2
var right_1: Vector2
var right_2: Vector2
var table_spot: Vector2
var leave_dir: Vector2
var target_position: Array[Vector2] =[]


var current_target_index: int = 0

func _ready() -> void:
	slot.item_data = MASK_02
	print("name: %s\nbuy: %s\nqty: %s" %[slot.item_data.name,slot.item_data.sell,slot.quantity])
	call_deferred("assign_marker")

func assign_marker():
	end_left = get_parent().end_left_marker.global_position
	end_right = get_parent().end_right_marker.global_position
	table_spot = get_parent().table_marker.global_position
	left_1 = get_parent().left_marker_1.global_position
	left_2 = get_parent().left_marker_2.global_position
	mid = get_parent().mid_marker.global_position
	right_1 = get_parent().right_marker_1.global_position
	right_2 = get_parent().right_marker_2.global_position
	
	randomize()
	var ran = randf()
	if ran >= 0.8:
		nav2d.target_position = left_1
	elif ran >= 0.6:
		nav2d.target_position = left_2
	elif ran >= 0.4:
		nav2d.target_position = mid
	elif ran >= 0.2:
		nav2d.target_position = right_2
	elif ran >= 0.0:
		nav2d.target_position = right_1
	var ran_leave = randf()
	if ran_leave >= 0.5:
		leave_dir = end_left
	elif ran_leave <0.5:
		leave_dir = end_right

func _physics_process(delta):
	handle_movement()
	move_and_slide()
	handle_animation()
	navigate(delta)
	interact()

func navigate(delta:float) -> void:
	if nav2d.is_target_reached():
		velocity = Vector2.ZERO
		await get_tree().create_timer(2).timeout
		to_table(delta)
		return
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity= (global_position.direction_to(next_path_position) * speed)
	position += velocity * delta

func to_table(delta) -> void:
	nav2d.target_position = table_spot
	if nav2d.is_navigation_finished():
		velocity = Vector2.ZERO
		await get_tree().create_timer(2).timeout
		buy()
		leave(delta)
		return
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity= (
		global_position.direction_to(next_path_position) * speed
	)
	position += velocity * delta

func buy() -> void:
	if table_inv:
		var slot_data = table_inv.slot_datas
		for i in range(slot_data.size()):
			if slot_data[i] and slot_data[i].item_data.name == slot.item_data.name:
				print("found")
				return
			else:
				print('not found')
				return
	else:
		return

func leave(delta) -> void:
	nav2d.target_position = leave_dir
	if nav2d.is_navigation_finished():
		queue_free()
		return
	var next_path_position: Vector2 = nav2d.get_next_path_position()
	velocity= (
		global_position.direction_to(next_path_position) * speed
	)
	position += velocity * delta

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
