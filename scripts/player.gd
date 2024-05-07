extends CharacterBody2D

@export var starting_direction : Vector2 = Vector2(-1,0)
@export var inv: Inv
@onready var animation_tree := $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
var health : int
# parameters/Idle/blend_position

const walk_speed = 125
var facing_direction : Vector2 = Vector2.ZERO
var shooting : bool
var meleeing : bool
var bow_equipt = true
var sword_equipt = true
var arrow = preload("res://scenes/arrow.tscn")

func player():
	pass

func _ready():
	animation_tree.active = true
	shooting = false
	meleeing = false
	health = 5
	update_animation_parameters()

func _process(_delta):
	update_animation_parameters()

func _physics_process(_delta):
	# Movement controls
	var direction : Vector2 = Input.get_vector("left","right","up","down").normalized()
	if Input.is_action_just_pressed("death_button"):
		health = 0
	
	if direction and health:
		if !shooting and !meleeing:
			velocity = direction * walk_speed
		else:
			velocity = direction * 65
		facing_direction = direction
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func update_animation_parameters():
	var marker_position = $Marker2D.global_position
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - marker_position).normalized()
	$Marker2D.look_at(mouse_pos)
	
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	
	if Input.is_action_just_pressed("shoot") and !shooting and bow_equipt:
		animation_tree["parameters/conditions/shoot"] = true
		shooting = true
		var arrow_instance = arrow.instantiate()
		arrow_instance.rotation = $Marker2D.rotation
		arrow_instance.global_position = $Marker2D.global_position
		add_child(arrow_instance)
		$Attack_Timer.wait_time = 0.9
		$Attack_Timer.start()
	else:
		animation_tree["parameters/conditions/shoot"] = false
	
	if Input.is_action_just_pressed("melee") and !meleeing and sword_equipt:
		animation_tree["parameters/conditions/melee"] = true
		meleeing = true
		$Attack_Timer.wait_time = 0.5
		$Attack_Timer.start()
	else:
		animation_tree["parameters/conditions/melee"] = false
	
	if health == 0:
		animation_tree["parameters/conditions/no_health"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = false
	
	animation_tree["parameters/Idle/blend_position"]= facing_direction
	animation_tree["parameters/Walk/blend_position"]= facing_direction
	animation_tree["parameters/Death/blend_position"]= facing_direction
	if !shooting:
		animation_tree["parameters/Shoot/blend_position"]= attack_direction
	if !meleeing:
		animation_tree["parameters/Melee/blend_position"]= attack_direction

func _on_shooting_timer_timeout():
	shooting = false
	meleeing = false

func collect(item):
	inv.insert(item)
