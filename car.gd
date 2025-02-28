extends CharacterBody3D

const TURN_SPEED = 0.3
const MAX_SPEED = 12.0
const FORWARD_TRACTION = 10
const SIDE_TRACTION = 8

# as soon as you go into the air it switches to using pure vec3

# should probably remember to use delta in calculations
func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		
		var local_velocity = velocity * transform.basis.get_rotation_quaternion()
		
		var forward_wheel_velocity = local_velocity.z
		var side_wheel_velocity = local_velocity.x
		
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# wheel coercion: when grounded, side wheel velocity fizzles out to make us go straight
		side_wheel_velocity = move_toward(side_wheel_velocity, 0, delta * SIDE_TRACTION)
		
		# wheel propulsion: when grounded and throttling, the car's velocity will increase in the forward direction
		forward_wheel_velocity = move_toward(forward_wheel_velocity, input_dir.y * MAX_SPEED, delta * FORWARD_TRACTION)
		
		if (forward_wheel_velocity > MAX_SPEED):
			forward_wheel_velocity = MAX_SPEED
		
		# apply velocity
		var translational_velocity = Vector3(side_wheel_velocity, 0, forward_wheel_velocity) * transform.basis.get_rotation_quaternion().inverse()
		
		velocity.x = translational_velocity.x
		velocity.z = translational_velocity.z
		
		# when you turn, the car turns at a rate proportional to the magnitude of the move vector
		rotation.y -= input_dir.x * velocity.length() * TURN_SPEED * delta
		
	else:
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	
	
	

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
