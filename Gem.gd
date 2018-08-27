extends Area2D

onready var anim = get_node("anim")

func _ready():
	var new_anim = "Idle"
	anim.play(new_anim)
	
func _physics_process(delta):
	pass

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		get_node("../Player").collectCoin()
		queue_free()
