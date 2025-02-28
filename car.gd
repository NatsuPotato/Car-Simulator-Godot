extends RigidBody3D

const TURN_SPEED = 0.3
const MAX_SPEED = 12.0
const FORWARD_TRACTION = 10
const SIDE_TRACTION = 8

# should probably remember to use delta in calculations
func _physics_process(delta: float) -> void:
	
	# check if grounded
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position, position + Vector3(0, -0.5, 0))
	var result = space_state.intersect_ray(query)
	
	if (not result.is_empty()):
		
		var local_velocity = linear_velocity * transform.basis.get_rotation_quaternion()
		
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
		
		linear_velocity.x = translational_velocity.x
		linear_velocity.z = translational_velocity.z
		
		# when you turn, the car turns at a rate proportional to the magnitude of the move vector
		rotation.y -= input_dir.x * linear_velocity.length() * TURN_SPEED * delta
	
	
	
	

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






#func _physics_process(delta: float) -> void:
	#
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#
	## wheel coercion: when grounded, side wheel velocity fizzles out to make us go straight
	#
	## wheel propulsion: when grounded and throttling, the car's velocity will increase in the forward direction
	#apply_central_force(Vector3(0, 0, input_dir.y * 10) * transform.basis.get_rotation_quaternion().inverse())
	#
	## when you turn, the car turns at a rate proportional to the magnitude of the move vector
	#rotation.y -= input_dir.x * linear_velocity.length() * TURN_SPEED * delta
