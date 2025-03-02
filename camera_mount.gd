extends Node3D

const FOLLOW_SPEED = 4

@export var target : Node3D

func _process(delta: float) -> void:
	
	# stay fixed to position of target
	position = target.position
	
	# lerp to rotation of target
	var current_rot = transform.basis.get_rotation_quaternion()
	var target_rot = Quaternion(Vector3(0, 1, 0), target.rotation.y)
	
	rotation = current_rot.slerp(target_rot, delta * FOLLOW_SPEED).get_euler()
