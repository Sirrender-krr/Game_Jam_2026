extends Control
@onready var day_label: Label = $PanelContainer/DayLabel
@onready var gain_label: Label = $PanelContainer/GainLabel
@onready var spend_label: Label = $PanelContainer/SpendLabel
@onready var earn_label: Label = $PanelContainer/EarnLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tap_sound: AudioStreamPlayer2D = $TapSound


var day: int
var coin_gain
var coin_spend


func _ready() -> void:
	animation_player.play("reveal")
	day = GameManager.day
	coin_gain = GameManager.coin_gain
	coin_spend = GameManager.coin_loss
	day_label.text = "Day %d" % day
	gain_label.text = format_with_commas(coin_gain)
	if coin_spend != 0:
		spend_label.text = "-%s" % format_with_commas(coin_spend)
	else:
		spend_label.text = format_with_commas(coin_spend)
	earn_label.text = format_with_commas(coin_gain - coin_spend)
	check_result_color()

func _on_ok_button_pressed() -> void:
	var world = load("res://scenes/world.tscn")
	tap_sound.play()
	await get_tree().create_timer(0.5).timeout
	GameManager.clear_balance()
	GameManager.day +=1
	if get_tree().paused == true:
		get_tree().paused = false
	
	get_tree().change_scene_to_packed(world)

func format_with_commas(value: int) -> String:
	# 1. Determine if it's negative and use the absolute (positive) value
	var is_negative = value < 0
	var s = str(abs(value))
	
	var result = ""
	var count = 0
	
	# 2. Run the same loop logic on the positive string
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count == 3 and i > 0:
			result = "," + result
			count = 0
	
	# 3. If it was negative, add the sign back to the very front
	if is_negative:
		result = "-" + result
		
	return result

func check_result_color() -> void:
	if coin_gain - coin_spend > 0:
		earn_label.add_theme_color_override("font_color",gain_label.get_theme_color("font_color"))
	elif coin_gain - coin_spend < 0:
		earn_label.add_theme_color_override("font_color",spend_label.get_theme_color("font_color"))
	elif coin_gain - coin_spend == 0:
		earn_label.add_theme_color_override("font_color",Color(1.0,1.0,1.0))
