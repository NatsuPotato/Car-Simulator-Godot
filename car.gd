extends CharacterBody3D

const TURN_SPEED = 0.08
const MAX_SPEED = 20.0
const TRACTION = 0.3 # traction affects acceleration and drift

# should probably remember to use delta in calculations
func _physics_process(delta: float) -> void:
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# when you turn, the car turns at a rate proportional to the magnitude of the move vector
	rotation.y -= input_dir.x * velocity.length() * TURN_SPEED / MAX_SPEED
	
	# when you accelerate, you add the forward vector * acceleration to the move vector
	velocity += Vector3(0, 0, input_dir.y).rotated(up_direction, rotation.y) * TRACTION
	
	# cap the speed
	if (velocity.length() > MAX_SPEED):
		velocity = velocity.normalized() * MAX_SPEED
	
	# the drag on the move vector is proportional to the dot product between the forward vector and the move vector
	# unimplemented
	
	move_and_slide()
	
	
	
	
	
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
