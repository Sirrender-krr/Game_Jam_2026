extends CharacterBody2D
class_name Player

signal toggle_inventory

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export var inventory_data: InventoryData
var interacting

const speed = 40.0
const run_speed = 80
var accel = speed

enum dir {left, right, up, down}
enum State {idle, walk}
var direction = dir.down
var state = State.idle


func get_input():#easy get input, must bind key with get_vector() accordingly
	var input_direction = Input.get_vector('left','right','up','down')
	velocity = input_direction * accel

func _physics_process(_delta):
	get_input()
	handle_movement()
	move_and_slide()
	handle_animation()
	handle_running()
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	interact()

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

func handle_running() -> void:
	if can_run():
		if Input.is_action_pressed('run'):
			accel = run_speed
		if Input.is_action_just_released('run'):
			accel= speed
	else:
		accel = speed

func interact() -> void:
	if can_interact() and Input.is_action_just_pressed("interact")\
	 and interacting:
		interacting.player_interact()
	else:
		pass
