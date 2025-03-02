extends RigidBody3D

# As good practice, you should replace UI actions with custom gameplay actions.
# Input.is_action_just_pressed("ui_accept")
# move_toward(a, b, lerp)

# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
@export var TURN_SPEED : float = 0.13
@export var MAX_SPEED : float = 10.0
@export var FORWARD_TRACTION : float = 6
@export var LATERAL_TRACTION : float = 8

@export var GROUNDED_RAY_START : Vector3
@export var GROUNDED_RAY_END : Vector3

# I kinda wanna overhaul everything to be wheel based
# both front and back wheels apply a lateral drag force, countering spin and drift

func _physics_process(delta: float) -> void:
	
	var basis_rotation := transform.basis.get_rotation_quaternion()
	
	# check if wheels are grounded
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(position + GROUNDED_RAY_START * basis_rotation, position + GROUNDED_RAY_END * basis_rotation)
	var result := space_state.intersect_ray(query)
	
	if (result.is_empty()):
		# if wheels aren't on the ground, have normal friction
		physics_material_override.friction = 1
	else:
		# if wheels are on the ground, we will handle friction ourselves
		physics_material_override.friction = 0
		
		var local_velocity := linear_velocity * basis_rotation
		
		var forward_wheel_velocity := local_velocity.z
		var lateral_wheel_velocity := local_velocity.x
		
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# wheel coercion: the car's lateral movement always fissles out
		apply_central_force(Vector3(-lateral_wheel_velocity * LATERAL_TRACTION, 0, 0) * basis_rotation.inverse())
		
		# wheel propulsion: the car's forward acceleration is dependent on
		# 1) if you're throttling
		# 2) how fast you're already going forward
		apply_central_force(Vector3(0, 0, input_dir.y * FORWARD_TRACTION * (1 - abs(forward_wheel_velocity) / MAX_SPEED)) * basis_rotation.inverse())
		
		# when you turn, the car turns at a rate proportional to forward speed
		# and inversely proportional to rotational speed
		# (also when not turning, apply a "rotational drag" torque opposite of rotation)
		if (abs(input_dir.x) > 0.01):
			apply_torque(Vector3(0, input_dir.x * forward_wheel_velocity * TURN_SPEED / (1 + abs(angular_velocity.y)), 0))
		else:
			apply_torque(Vector3(0, -angular_velocity.y * abs(forward_wheel_velocity) * TURN_SPEED, 0))
