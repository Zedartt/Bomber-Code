extends Control

@onready var username_field: LineEdit = $LineEdit
@onready var password_field: LineEdit = $LineEdit2

@onready var login_button: BaseButton     = $connexion_button
@onready var register_button: BaseButton  = $inscription_button
@onready var status_label: Label          = $StatusLabel

var http: HTTPRequest

const API_BASE_URL := "http://srvg4bc.ddns.net"
const LOGIN_URL    := API_BASE_URL + "/login"

const REGISTER_SCENE_PATH := "res://inscription.tscn"


func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)

	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_go_to_register)

	status_label.text = ""


func _on_go_to_register() -> void:
	get_tree().change_scene_to_file(REGISTER_SCENE_PATH)


func _on_login_pressed() -> void:
	var username := username_field.text.strip_edges()
	var password := password_field.text

	if username == "" or password == "":
		status_label.text = "Entre ton pseudo et ton mot de passe."
		return

	status_label.text = "Connexion en cours..."

	var body := {
		"username": username,
		"passw": password
	}
	var json_body := JSON.stringify(body)
	var headers := ["Content-Type: application/json"]

	var err := http.request(LOGIN_URL, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		status_label.text = "Erreur réseau (code %s)" % err


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		status_label.text = "Erreur de connexion réseau."
		return

	var text := body.get_string_from_utf8()

	if response_code == 200 or response_code == 201:
		status_label.text = "Connexion réussie"
		get_tree().change_scene_to_file("res://MainMenu.tscn")

	elif response_code == 400 or response_code == 401:
		status_label.text = "Nom d’utilisateur ou mot de passe incorrect"

	elif response_code >= 500:
		status_label.text = "Erreur serveur, réessaie plus tard."

	else:
		status_label.text = "Erreur inconnue (%d)" % response_code


func _on_guest_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
