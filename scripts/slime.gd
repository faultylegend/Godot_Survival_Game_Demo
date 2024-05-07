extends CharacterBody2D

@onready var animation_tree := $AnimationTree
@onready var raycasts:= get_node("Raycasts")
var slime = preload("res://scenes/slime_collectable.tscn")
var max_steering: float = 2
var max_speed = 70
var mass = 1
var avoid_force:= 500

var health = 60 
var damage
var dead:= false
var player_in_area = false
var player = null

func enemy():
	pass

func _ready():
	dead = false

func _physics_process(_delta):
	if !dead:
		$detection/CollisionShape2D.disabled = false
		if player_in_area:
			var steering: Vector2 = Vector2.ZERO
			steering += seek_steering(player.global_position)
			steering += avoid_obstacles_steering()
			steering = steering.limit_length(max_steering) / mass
			
			velocity += steering
			velocity = velocity.limit_length(max_speed)
			
			animation_tree["parameters/conditions/move"] = true
			animation_tree["parameters/conditions/stay"] = false
			move_and_slide()
		else:
			animation_tree["parameters/conditions/move"] = false
			animation_tree["parameters/conditions/stay"] = true
	else:
		$detection/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
		animation_tree["parameters/conditions/dead"] = true
		await get_tree().create_timer(1).timeout
		var slime_instance = slime.instantiate()
		slime_instance.global_position = $Marker2D.global_position
		get_parent().add_child(slime_instance)
		print("drop slime")
		queue_free()

func seek_steering(player_position) -> Vector2:
	var desired_velocity : Vector2 = (player_position - global_position).normalized() * max_speed
	return desired_velocity - velocity

func avoid_obstacles_steering() -> Vector2:
	raycasts.rotation = velocity.angle()
	for raycast in raycasts.get_children():
		raycast.target_position.x = velocity.length()
		if raycast.is_colliding():
			var obstacle = raycast.get_collider()
			return (position + velocity - obstacle.position).normalized() * avoid_force
	
	return Vector2.ZERO

func pursuit():
	var distance: Vector2 = player.global_position - position
	var t = distance.length() / max_speed
	var futurePosition = player.global_position + player.velocity * t
	return seek_steering(futurePosition)

func _on_detection_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body


#func _on_detection_body_exited(body):
	#if body.has_method("player"):
		#player_in_area = false

func take_damage(damage):
	health -= damage
	if health <= 0:
		dead = true
