extends CharacterBody2D

# Exported properties
@export var max_velocity: float = 400.0
@export var acceleration: float = 50.0
@export var deceleration: float = 40.0
@export var rotation_speed: float = 0.02
@export var gravity: float = 10.0

# Internal variables
var direction := Vector2(1, 0)  # Initially pointing right
var crashed := false

# Signals
signal crashed

func _ready() -> void:
    # Connect to the body's area to detect collisions
    if has_node("CollisionShape2D"):
        var collision_shape = $CollisionShape2D
        collision_shape.connect("body_entered", self, "_on_body_entered")
    else:
        printerr("Missing CollisionShape2D node!")


func _physics_process(delta: float) -> void:
    # Handle movement controls
    _handle_rotation_controls(delta)
    _handle_velocity_controls(delta)

    # Apply gravity when velocity is zero
    if velocity == Vector2.ZERO and not Input.is_action_pressed("accelerate"):
        velocity.y += gravity * delta

    # Update direction vector based on the current rotation
    direction = Vector2(cos(rotation), sin(rotation))

    # Move the character using `move_and_slide`
    velocity = move_and_slide(velocity)

    # Clamp rotation within -45 to 45 degrees (in radians)
    var clamped_rotation = clamp(rotation, deg_to_rad(-45), deg_to_rad(45))
    rotation = clamped_rotation


func _handle_rotation_controls(delta: float) -> void:
    if Input.is_action_pressed("rotate_counterclockwise"):
        rotation -= rotation_speed * delta
    elif Input.is_action_pressed("rotate_clockwise"):
        rotation += rotation_speed * delta


func _handle_velocity_controls(delta: float) -> void:
    if Input.is_action_pressed("accelerate"):
        velocity += direction * acceleration * delta
        velocity = velocity.clamped(max_velocity)
    elif Input.is_action_pressed("decelerate"):
        velocity -= direction * deceleration * delta
        if velocity.length() < 0.01:
            velocity = Vector2.ZERO


func _on_body_entered(body) -> void:
    if not crashed:
        crashed = true
        emit_signal("crashed")
