extends CharacterBody2D

@export var speed: float = 130.0
@export var throw_force: float = 450.0

@onready var hold_point: Marker2D = $HoldPoint
@onready var pickup_zone: Area2D = $PickupZone

var held_prop: ThrowableProp = null

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * speed
	move_and_slide()

	var mouse_direction := (get_global_mouse_position() - global_position).normalized()
	hold_point.position = mouse_direction * 16.0

	if is_instance_valid(held_prop) and held_prop.is_held:
		held_prop.global_position = hold_point.global_position
		held_prop.rotation = mouse_direction.angle()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if held_prop:
			release_held_prop()
		else:
			attempt_pickup()
	elif event.is_action_pressed("attack") and held_prop:
		throw_held_prop()

func attempt_pickup() -> void:
	var bodies = pickup_zone.get_overlapping_bodies()
	for body in bodies:
		if body is ThrowableProp and not body.is_held:
			held_prop = body
			held_prop.pick_up()
			break

func throw_held_prop() -> void:
	var throw_direction := (get_global_mouse_position() - hold_point.global_position).normalized()
	var prop := held_prop
	held_prop = null
	prop.launch(throw_direction, throw_force)

func release_held_prop() -> void:
	held_prop.drop()
	held_prop = null
