extends Polygon2D

@export var start_visible_time_sec: float
@export var visibility_time_sec: float = 5

var start_timer: Timer
var disappear_timer: Timer

func _init(start_visible_time_sec: float = 2) -> void:
	self.start_visible_time_sec = start_visible_time_sec
	

func _ready() -> void:
	visible = false
	start_timer = Timer.new()
	start_timer.one_shot = true
	add_child(start_timer)
	disappear_timer = Timer.new()
	disappear_timer.one_shot = true
	add_child(disappear_timer)
	start_timer.timeout.connect(_display)
	start_timer.start(start_visible_time_sec)


func _display() -> void:
	self.visible = true
	disappear_timer.timeout.connect(_disappear)
	disappear_timer.start(visibility_time_sec)
	
	
func _disappear() -> void:
	queue_free()
