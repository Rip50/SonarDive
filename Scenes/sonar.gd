extends Node2D

@export var rays_count: int = 1024
@export var ray_length: int = 1024
@export var sonar_velocity: float = 300.0
@export var cooldown_sec: int = 5

var rays: Array[RayCast2D] = []
var cooldown_timer: Timer
var scan_ready := true


func _ready() -> void:
    var rotation_step := 2*PI/rays_count
    var target := Vector2(ray_length, 0)
    for i in range(rays_count):
        var ray := RayCast2D()
        ray.target_position = target.rotated(i * rotation_step)
        ray.enabled = true
        rays.push_back(ray)
        add_child(ray)

    cooldown_timer = Timer()
    cooldown_timer.one_shot = true
    cooldown_timer.connect("timeout", self, "set_scan_ready")
    add_child(cooldown_timer)


func _physics_process(_delta: float) -> void:
    if not scan_ready:
        return

    if Input.is_action_pressed("scan"):
        scan()


func scan() -> void:
    scan_ready = false
    cooldown_timer.start(cooldown_sec)

    for ray in rays:
        ray.force_raycast_update()  # Update the RayCast2D to check for intersections
        if ray.is_colliding():
            var collision_point = ray.get_collision_point()
            var distance = collision_point.distance_to(ray.global_position)
            var delay = distance / sonar_velocity
            var dot = Dot.new(delay)
            dot.global_position = collision_point
            add_child(dot)


func set_scan_ready() -> void:
    scan_ready = true
