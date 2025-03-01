extends RigidBody3D

const TURN_SPEED : float = 0.13
const MAX_SPEED : float = 10.0
const FORWARD_TRACTION : float = 6
const LATERAL_TRACTION : float = 8

var grounded_vector_start
var grounded_vector_end

func _ready() -> void:
	var grounded_vectors : PackedVector3Array = get_meta("GroundedVectors")
	grounded_vector_start = grounded_vectors[0]
	grounded_vector_end = grounded_vectors[1]

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
	var query := PhysicsRayQueryParameters3D.create(position + grounded_vector_start, position + grounded_vector_end)
	var result := space_state.intersect_ray(query)
	
	if (not result.is_empty()):
		
		var basis_rotation := transform.basis.get_rotation_quaternion()
		
		var local_velocity := linear_velocity * basis_rotation
		
		var forward_wheel_velocity := local_velocity.z
		var lateral_wheel_velocity := local_velocity.x
		
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# wheel coercion:
		# the car's lateral movement always fissles out
		apply_central_force(Vector3(-lateral_wheel_velocity * LATERAL_TRACTION, 0, 0) * basis_rotation.inverse())
		
		print(forward_wheel_velocity)
		# wheel propulsion:
		# the car's forward movement is dependent on if/how you're throttling
		apply_central_force(Vector3(0, 0, input_dir.y * FORWARD_TRACTION * (1 - abs(forward_wheel_velocity) / MAX_SPEED)) * basis_rotation.inverse())
		
		# when you turn, the car turns at a rate proportional to the magnitude of the move vector
		rotation.y += input_dir.x * forward_wheel_velocity * TURN_SPEED * delta
