extends Sprite2D

var sensitivity := 2.0

func _process(delta):
	# Verifica se a função existe
	if Input.has_method("get_accelerometer"):
		var accel = Input.get_accelerometer()
		rotation_degrees = -accel.x * sensitivity * 90
