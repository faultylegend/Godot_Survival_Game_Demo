extends StaticBody2D

@export var item: InvItem
var player = null

func _on_interactable_area_body_entered(body):
	if body.has_method("player"):
		player = body
		playercollect()
		await get_tree().create_timer(.1).timeout
		self.queue_free()


func playercollect():
	player.collect(item)
