extends Node2D

@onready var animplayer = $world2cutscene/AnimationPlayer
@onready var camera = $world2cutscene/Path2D/PathFollow2D/Camera2D
var play_cutscene = false
var player_entered_area = false
var player = null

var is_path_following = false
var smoke_effect_finish = false
var smoke_effect = false

func _ready():
	camera.enabled = false
	$world2cutscene.visible = true
	$world2main.visible = false
	$world2cutscene/Path2D/PathFollow2D.progress_ratio = 0

func _physics_process(delta):
	if play_cutscene and is_path_following:
		var path_follower = $world2cutscene/Path2D/PathFollow2D
		if !smoke_effect:
			path_follower.progress_ratio += 0.0015
		
		if path_follower.progress_ratio >= 0.99:
			end_cutscene()
		
		if path_follower.progress_ratio >= 0.96 and !smoke_effect_finish and !smoke_effect:
			var smoke_screen = $world2cutscene/SmokeScreen
			smoke_effect = true
			for smoke in smoke_screen.get_children():
				smoke["emitting"] = true
			await get_tree().create_timer(1.5).timeout
			$world2cutscene/TileMapFinished.visible = true
			$world2cutscene/TileMapUnfinished.visible = false
			for smoke in smoke_screen.get_children():
				smoke["emitting"] = false
			await get_tree().create_timer(0.5).timeout
			smoke_effect_finish = true
			smoke_effect = false

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
