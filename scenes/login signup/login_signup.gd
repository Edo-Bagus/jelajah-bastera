extends Control

@onready var email_line = $Panel/VBoxContainer/EmailLine
@onready var password_line = $Panel/VBoxContainer/PasswordLine
@onready var status_label = $Panel/StatusLabel
@onready var http = $HTTPRequest

var supabase_url = "https://kcrglneppkjtdoatdvzr.supabase.co"
var supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtjcmdsbmVwcGtqdGRvYXRkdnpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNTcxNTEsImV4cCI6MjA3MDYzMzE1MX0.gg9dMyUs-SSZJNRld6hqC_a1syZH_J4nPwc6JfFBXiI"

func _ready() -> void:
	Global.play_music(preload("res://assets/Sound/Main Menu.mp3"))
	Global.music_player.stream.loop = true
# --------------- SIGNUP ----------------
func _on_SignupButton_pressed():
	var email = email_line.text
	var password = password_line.text
	var url = supabase_url + "/auth/v1/signup"
	var headers = [
		"apikey: " + supabase_key,
		"Content-Type: application/json"
	]
	var body = {
		"email": email,
		"password": password
	}
	status_label.text = "Mendaftar..."
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

# --------------- LOGIN ----------------
func _on_LoginButton_pressed():
	var email = email_line.text
	var password = password_line.text
	var url = supabase_url + "/auth/v1/token?grant_type=password"
	var headers = [
		"apikey: " + supabase_key,
		"Content-Type: application/json"
	]
	var body = {
		"email": email,
		"password": password
	}
	status_label.text = "Login..."
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

# --------------- RESPONSE HANDLER ----------------
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	if response_code == 200:
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY:
			if data.has("access_token"): # response login
				Global.access_token = data["access_token"]
				Global.user_id = data["user"]["id"]
				print(data)
				status_label.text = "Login sukses!"
				#print("Login sukses! User ID:", Global.user_id)
				get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")
			else: # response signup
				status_label.text = "Signup berhasil! Silakan login."
		else:
			status_label.text = "Format response tidak dikenali."
	else:
		# coba parse JSON error
		var err_data = JSON.parse_string(text)
		if typeof(err_data) == TYPE_DICTIONARY:
			if err_data.has("msg"):
				status_label.text = err_data["msg"]
			elif err_data.has("message"):
				status_label.text = err_data["message"]
			else:
				status_label.text = str(err_data)
		else:
			status_label.text = text   # fallback kalau bukan JSON
