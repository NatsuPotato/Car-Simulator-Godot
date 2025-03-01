extends RigidBody3D

const TURN_SPEED : float = 0.13
const MAX_SPEED : float = 20.0
const FORWARD_TRACTION : float = 10
const LATERAL_TRACTION : float = 2

# TODO
# visible wheel turning
# turning system (dependent on move speed) is pretty bad

# As good practice, you should replace UI actions with custom gameplay actions.
# Input.is_action_just_pressed("ui_accept")
# move_toward(a, b, lerp)
# should probably remember to use delta in calculations
# also rigidbodies prefer using forces over directly modifying velocities
func _physics_process(delta: float) -> void:
	
	# check if grounded
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(position + Vector3(0, 0.1, 0), position + Vector3(0, -0.5, 0))
	var result := space_state.intersect_ray(query)
	
	if (not result.is_empty()):
		
		var local_velocity := linear_velocity * transform.basis.get_rotation_quaternion()
		
		var forward_wheel_velocity := local_velocity.z
		var lateral_wheel_velocity := local_velocity.x
		
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# wheel coercion:
		# the car's lateral movement always fissles out
		apply_central_force(Vector3(-lateral_wheel_velocity * LATERAL_TRACTION, 0, 0) * transform.basis.get_rotation_quaternion().inverse())
		
		# wheel propulsion:
		# the car's forward movement is dependent on if/how you're throttling
		apply_central_force(Vector3(0, 0, input_dir.y * FORWARD_TRACTION) * transform.basis.get_rotation_quaternion().inverse())
		
		# when you turn, the car turns at a rate proportional to the magnitude of the move vector
		rotation.y += input_dir.x * forward_wheel_velocity * TURN_SPEED * delta
