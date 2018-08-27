extends KinematicBody2D

var velocity = Vector2()
#Gravité
export var GRAVITY = 250
export var MAX_FALLING_SPEED = 40
#Déplacement
export var MOVE_SPEED = 125
export var MOVE_SPEED_TIME_NEEDED = 0.2
var move_step
export var DECELERATION_TIME_NEEDED = 0.2
var dec_step
#Jump
export var MAX_JUMP_POWER = 180
export var MIN_JUMP_POWER = 100
var is_jump_pressed = false
var last_frame_grounded = false
#Gestion de la direction pour la caméra
var facing_dir = 1

#Animation 
onready var sprite = get_node("Sprite")
var last_anim = ""
onready var anim = get_node("anim")

func _ready():
	move_step = MOVE_SPEED / MOVE_SPEED_TIME_NEEDED
	dec_step = MOVE_SPEED / DECELERATION_TIME_NEEDED

func _physics_process(delta):
	var movement = Vector2(velocity.x, velocity.y + GRAVITY * delta)
	#Récupération des inputs
	var right_input = Input.is_action_pressed("right")
	var left_input = Input.is_action_pressed("left")
	var jump_input = Input.is_action_pressed("jump")
	#Déplacement
	if right_input:
		movement.x += move_step * delta
	elif left_input:
		movement.x -= move_step * delta
	elif movement.x != 0:
		var _dir = sign(movement.x)
		var _dec = _dir * -1 * dec_step
		movement.x += _dec * delta
		#Stop le mouvement lorsqu'il atteint 0
		if _dir == 1 && movement.x < 0:
			movement.x = 0
		elif _dir == -1 && movement.x > 0:
			movement.x = 0
	#Si la vitesse horizontale est supérieure à MOVE_SPEED, on la limite
	if abs(movement.x) > MOVE_SPEED:
		movement.x = sign(movement.x) * MOVE_SPEED
	#Gestion du saut
	if jump_input:
		if !is_jump_pressed && last_frame_grounded:
			movement.y = -MAX_JUMP_POWER
			is_jump_pressed = true
	elif !jump_input && is_jump_pressed:
		if movement.y < -MIN_JUMP_POWER:
			movement.y = -MIN_JUMP_POWER
		is_jump_pressed = false
	#Permettre le saut uniquement lorsque le player touche le sol
	if is_on_floor():
		last_frame_grounded = true
	else:
		last_frame_grounded = false
	
	#Si la vitesse verticale est supérieure à MAX_FALLING_SPEED, on la limite
	if velocity.y > MAX_FALLING_SPEED:
		velocity.y = MAX_FALLING_SPEED
		
	if velocity.x != 0:
		facing_dir = sign(velocity.x)
		
	velocity = movement
		
	#Déplacement du personnage
	move_and_slide(velocity, Vector2(0, -1))
	
	#Gestion des animations 
	sprite.set_flip_h(facing_dir != 1)
	var new_anim = "Idle"
	if last_frame_grounded:
		if velocity.x != 0:
			new_anim = "Run"
	else:
		new_anim = "Jump"
	#apply animation
	if new_anim != last_anim:
		anim.play(new_anim)
		last_anim = new_anim
	
func get_center_pos():
	return position + get_node("CollisionPolygon2D").position
	
func collectCoin():
	get_node("/root/Global").gemCounter += 1
	var message = 'I have ' + str(get_node("/root/Global").gemCounter) + ' coins!'
	get_node('labelDialog').set_text(message)
	get_node('timerDialog').start()

func _on_timerDialog_timeout():
	get_node('labelDialog').set_text('')

