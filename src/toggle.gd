extends SpotLight3D

var on = true
var audioserver: AudioStreamPlayer3D
var canInteract = true
var interactionCooldown = .5
var timeSinceLastInteraction = 0.0

func _ready():
	audioserver = $Click
	pass

func _process(delta):
	timeSinceLastInteraction += delta
	
	if timeSinceLastInteraction >= interactionCooldown:
		canInteract = true
	
	if canInteract and Input.is_action_just_pressed("click"):
		audioserver.play()
		on = not on
		if on:
			show()
		else:
			hide()
		canInteract = false
		timeSinceLastInteraction = 0.0
	pass
