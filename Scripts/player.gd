extends CharacterBody2D

@export var speed: float = 130.0
@export var throw_force: float = 450.0

# Dash tuning parameters
@export var dash_speed: float = 380.0
@export var dash_duration: float = 0.2

@onready var hold_point: Marker2D = $HoldPoint
@onready var pickup_zone: Area2D = $PickupZone
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_bar = $DashBarTileMapLayer

var held_prop: ThrowableProp = null
var facing_direction: String = "front"

# Dash state variables
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.DOWN
var last_input_vector: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector != Vector2.ZERO:
		last_input_vector = input_vector.normalized()

	if is_dashing:
		# Lock velocity into the dash direction during the dash burst
		velocity = dash_direction * dash_speed
	else:
		velocity = input_vector * speed

	move_and_slide()

	if not is_dashing:
		update_animation(input_vector)

	# Keep hold point pointing at cursor
	var mouse_direction := (get_global_mouse_position() - global_position).normalized()
	hold_point.position = (mouse_direction * 16.0).round()
	hold_point.rotation = mouse_direction.angle()

func update_animation(input: Vector2) -> void:
	if input != Vector2.ZERO:
		if abs(input.x) > abs(input.y):
			facing_direction = "side"
			sprite.flip_h = input.x < 0
		else:
			facing_direction = "back" if input.y < 0 else "front"
			sprite.flip_h = false

		sprite.play("walk_" + facing_direction)
	else:
		sprite.play("idle_" + facing_direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if held_prop:
			release_held_prop()
		else:
			attempt_pickup()
	elif event.is_action_pressed("attack"):
		print("Attack pressed. Held prop is: ", held_prop)
		if held_prop:
			throw_held_prop()
		
	if event.is_action_pressed("dash"):
		if not is_dashing and dash_bar and dash_bar.use_dash():
			perform_dash()

func perform_dash() -> void:
	is_dashing = true
	
	# Dash towards movement direction; fallback to last faced direction if stationary
	var current_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	dash_direction = current_input.normalized() if current_input != Vector2.ZERO else last_input_vector

	# Optional juice: flash white or tint while dashing
	var original_modulate = sprite.modulate
	sprite.modulate = Color(1.8, 1.8, 2.2, 0.8) # Slight blue-white glow

	# Handle dash duration using a scene tree timer
	await get_tree().create_timer(dash_duration).timeout

	sprite.modulate = original_modulate
	is_dashing = false

func attempt_pickup() -> void:
	var bodies = pickup_zone.get_overlapping_bodies()
	for body in bodies:
		if body is ThrowableProp and not body.is_held:
			held_prop = body
			held_prop.pick_up(hold_point)
			break

func throw_held_prop() -> void:
	var throw_direction := (get_global_mouse_position() - hold_point.global_position).normalized()
	var prop := held_prop
	held_prop = null
	prop.launch(throw_direction, throw_force)

func release_held_prop() -> void:
	var prop := held_prop
	held_prop = null
	prop.drop()
