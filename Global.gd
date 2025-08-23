extends Node

var access_token: String = ""
var user_id: String = ""
var music_player: AudioStreamPlayer

var supabase_url = "https://kcrglneppkjtdoatdvzr.supabase.co"
var supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtjcmdsbmVwcGtqdGRvYXRkdnpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNTcxNTEsImV4cCI6MjA3MDYzMzE1MX0.gg9dMyUs-SSZJNRld6hqC_a1syZH_J4nPwc6JfFBXiI"

@onready var http_save := HTTPRequest.new()
@onready var http_get := HTTPRequest.new()

func _ready():
	add_child(http_save)
	add_child(http_get)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.autoplay = false
	music_player.stream_paused = false


	http_save.request_completed.connect(_on_save_completed)
	http_get.request_completed.connect(_on_get_completed)

# ===================== SAVE ======================
func save_highscore(level: int, score: int) -> void:
	var url = supabase_url + "/rest/v1/scores?on_conflict=user_id,level"
	var headers = [
		"apikey: " + supabase_key,
		"Authorization: Bearer " + access_token,
		"Content-Type: application/json",
		"Prefer: return=representation,resolution=merge-duplicates"
	]
	var body = {
		"user_id": user_id,
		"level": level,
		"highscore": score
	}

	var err = http_save.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		print("Request error:", err)

func _on_save_completed(result, response_code, headers, body):
	print("SAVE Response:", response_code, body.get_string_from_utf8())

# ===================== GET ======================
func get_highscore(level: int) -> int:
	var url = supabase_url + "/rest/v1/scores?user_id=eq." + user_id + "&level=eq." + str(level) + "&select=highscore"
	var headers = [
		"apikey: " + supabase_key,
		"Authorization: Bearer " + access_token
	]

	var err = http_get.request(url, headers, HTTPClient.METHOD_GET)

	var result = await http_get.request_completed
	var response_body = result[3].get_string_from_utf8()
	var response = JSON.parse_string(response_body)

	if typeof(response) == TYPE_ARRAY and response.size() > 0:
		print("ga muncul")
		return int(response[0]["highscore"])

	return -2

func _on_get_completed(result, response_code, headers, body):
	print("GET Response:", response_code, body.get_string_from_utf8())
	
func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

func stop_music():
	music_player.stop()
