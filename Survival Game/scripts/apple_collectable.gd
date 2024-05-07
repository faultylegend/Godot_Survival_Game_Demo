extends StaticBody2D


func _ready():
	fallfromtree()

func fallfromtree():
	$AnimationPlayer.play("falling")
	await get_tree().create_timer(1.5).timeout
	$AnimationPlayer.play("fade")
	print("+1 apple")
	await get_tree().create_timer(.3).timeout
	queue_free()
