extends CharacterBody2D

const SPEED = 100.0

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	elif Input.is_action_pressed("ui_left"):
		input_vector.x -= 1

	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	elif Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	if input_vector.x != 0:
		$AnimatedSprite2D.flip_h = (input_vector.x < 0)
		$AnimatedSprite2D.play("side_walk")
	elif input_vector.y < 0:
		$AnimatedSprite2D.play("back_walk")
	elif input_vector.y > 0:
		$AnimatedSprite2D.play("front_walk")
	else:
		$AnimatedSprite2D.play("side_idle") # adjust idle animations as needed

	var new_velocity = input_vector.normalized() * SPEED
	velocity.x = new_velocity.x
	velocity.y = new_velocity.y
	move_and_slide()
