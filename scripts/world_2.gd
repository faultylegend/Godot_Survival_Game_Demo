extends Node2D

@onready var animplayer = $world2cutscene/AnimationPlayer
@onready var camera = $world2cutscene/Path2D/PathFollow2D/Camera2D
var play_cutscene = false
var player_entered_area = false
var player = null

var is_path_following = false

func _ready():
	camera.enabled = false
	$world2cutscene.visible = true
	$world2main.visible = false

func _physics_process(delta):
	if play_cutscene and is_path_following:
		var path_follower = $world2cutscene/Path2D/PathFollow2D
		path_follower.progress_ratio += 0.001
		
		if path_follower.progress_ratio >= 0.99:
			end_cutscene()

func _on_player_detection_body_entered(body):
	if body.has_method("player") and !player_entered_area:
		player = body
		player_entered_area = true
		opening_cutscene()

func opening_cutscene():
	play_cutscene = true
	player.camera.enabled = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	animplayer.play("cover_fade")
	camera.enabled = true
	is_path_following = true


func end_cutscene():
	play_cutscene = false
	is_path_following = false
	camera.enabled = false
	player.camera.enabled = true
	$world2cutscene.visible = false
	$world2cutscene/TileMapUnfinished["layer_2/enabled"] = false
	$world2main.visible = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
