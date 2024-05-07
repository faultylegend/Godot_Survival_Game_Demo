extends Node2D

var state = "no_apples"
var player_in_area: bool

var apple = preload("res://scenes/apple_collectable.tscn")

@export var item: InvItem
var player = null

func _ready():
	player_in_area = false
	if state == "no_apples":
		$growth_timer.start()

func _process(delta):
	$AnimatedSprite2D.play(state)
	if state == "apples" and player_in_area and Input.is_action_just_pressed("interact"):
		state = "no_apples"
		drop_apple()	

func _on_pickable_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_pickable_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false


func _on_growth_timer_timeout():
	if state == "no_apples":
		state = "apples"

func drop_apple():
	await get_tree().create_timer(0).timeout
	var apple_instance = apple.instantiate()
	apple_instance.global_position = $Marker2D.global_position
	get_parent().add_child(apple_instance)
	player.collect(item)
	await get_tree().create_timer(3).timeout
	$growth_timer.start()
