extends CanvasModulate

signal time_tick(day:int, hour:int, minute:int)
signal day_end

const minutes_per_day = 1440
const minutes_per_hour = 60
const ingame_to_real_minute_duration = (2* PI)/minutes_per_day

@export var gradient: GradientTexture1D
@export var ingame_speed= 5.0 #1 realtime sec = x in-game minutes
@export var initial_hour = 8: #a start of the day time in hour
	set(h):
		initial_hour = h
		time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour
var current_day
var time: float = 0.0
var past_minute:float =-1.0
var force_day_end: int = 23

func _ready() -> void:
	time = ingame_to_real_minute_duration * initial_hour * minutes_per_hour
	current_day = GameManager.day

func _process(delta: float) -> void:
	time += delta * ingame_to_real_minute_duration * ingame_speed
	
	## a var to return 0.0 to 1.0 depends of delta
	var value = (sin(time - PI/2)+1.0)/2.0
	
	self.color = gradient.gradient.sample(value)
	
	_recalculate_time()

func _recalculate_time() -> void:
	var total_minutes = int(time/ingame_to_real_minute_duration) #in game minutes
	
	#current_day = int (total_minutes/minutes_per_day) #in game day(s)
	var current_day_minutes = total_minutes % minutes_per_day #the left over for each day
	var hour = int(current_day_minutes/minutes_per_hour)
	var minute = int(current_day_minutes % minutes_per_hour)
	if past_minute != minute: #this line is to opmize not send a signal too much
		past_minute = minute
		time_tick.emit(current_day,hour,minute)
		if hour == force_day_end:
			day_end.emit()
