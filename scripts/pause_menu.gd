extends Control


@onready var resume_anim: AnimatedSprite2D = $ResumeButton/ResumeAnim
@onready var restart_anim: AnimatedSprite2D = $RestartButton/RestartAnim
@onready var quit_anim: AnimatedSprite2D = $QuitButton/QuitAnim

func _ready() -> void:
	hide()


func resume() -> void:
	hide()
	get_tree().paused = false

func pause() -> void:
	show()
	get_tree().paused = true

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume_anim.play()
		await get_tree().create_timer(0.3).timeout
		resume()

func _on_resume_button_pressed() -> void:
	resume_anim.play()
	await get_tree().create_timer(0.3).timeout
	resume()


func _on_restart_button_pressed() -> void:
	restart_anim.play()
	await get_tree().create_timer(0.3).timeout
	resume()
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	quit_anim.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
