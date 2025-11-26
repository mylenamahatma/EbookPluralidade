extends Sprite2D

@export var speed := 25.0
@export var limit_x := 1200
@export var reset_x := -400

func _process(delta):
	position.x += speed * delta

	if position.x > limit_x:
		position.x = reset_x
