extends Control # or Node2D, depending on your setup

@onready var start_label = $Label

# This function will be called from GeneralLevel.gd
func start_countdown():
	start_label.text = "3"
	# Hide the label initially, then show it for the countdown
	start_label.show() 
	
	# Wait for 1 second
	await get_tree().create_timer(1.0).timeout
	
	start_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	
	start_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	# Hide the label after the countdown
	start_label.hide()
	
	# The 'await' in GeneralLevel.gd will handle the rest
