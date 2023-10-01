class_name PlayerCamera extends Camera3D

func _physics_process(delta):
	# _detect_interactions()
	pass

func shake():
	$ScreenShake.apply_shake()

