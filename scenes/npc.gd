extends CharacterBody2D

const speed = 30
var current_state = IDLE

var dir = Vector2.RIGHT
var start_pos

var is_roaming = true
var is_chatting = false

var player
var is_player_in_chat_zone = false

@onready var animation := $AnimationPlayer

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

func _ready():
	randomize()
	start_pos = position

func _process(delta):
	if current_state == 0 or current_state == 1:
		animation.play("idle")
	elif current_state == 2 and !is_chatting:
		if dir.x == -1:
			animation.play("walk_w")
		if dir.x == 1:
			animation.play("walk_e")
		if dir.y == -1:
			animation.play("walk_n")
		if dir.y == 1:
			animation.play("walk_s")
			
	if is_roaming: 
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.RIGHT,Vector2.UP,Vector2.DOWN,Vector2.LEFT])
			MOVE:
				move(delta)
	
	if Input.is_action_just_pressed("interact") and is_player_in_chat_zone:
		print("chatting")
		current_state = 0
		is_chatting = true
		is_roaming = false

func choose(array):
	array.shuffle()
	return array.front()

func move(delta):
	if !is_chatting:
		position += dir * speed * delta
		

func _on_chat_detection_body_entered(body):
	if body.has_method("player"):
		player = body
		is_player_in_chat_zone = true

func _on_chat_detection_body_exited(body):
	if body.has_method("player"):
		is_player_in_chat_zone = false
		is_chatting = false
		is_roaming = true



func _on_timer_timeout():
	$Timer.wait_time = choose([0.5,1,1.5])
	current_state = choose([IDLE,NEW_DIR,MOVE])
