extends Control

@onready var username_field: LineEdit = $LineEdit
@onready var password_field: LineEdit = $LineEdit2
@onready var confirm_field: LineEdit  = $LineEdit3
@onready var register_button: BaseButton = $register_button
@onready var back_button: BaseButton     = $back_button
@onready var status_label: Label         = $StatusLabel

var http: HTTPRequest

const API_BASE_URL := "http://srvg4bc.ddns.net"
const REGISTER_URL := API_BASE_URL + "/register"
const LOGIN_SCENE_PATH := "res://login.tscn"

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)

	register_button.pressed.connect(_on_register_pressed)
	back_button.pressed.connect(_on_back_pressed)

	status_label.text = ""

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(LOGIN_SCENE_PATH)

func _on_register_pressed() -> void:
	var username := username_field.text.strip_edges()
	var password := password_field.text
	var confirm  := confirm_field.text

	if username == "" or password == "" or confirm == "":
		status_label.text = "Remplis tous les champs."
		return

	if password != confirm:
		status_label.text = "Les mots de passe ne correspondent pas."
		return

	status_label.text = "Création du compte..."

	var body := {
		"username": username,
		"passw": password
	}
	var json_body := JSON.stringify(body)
	var headers := ["Content-Type: application/json"]

	var err := http.request(REGISTER_URL, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		status_label.text = "Erreur réseau (code %s)" % err

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		status_label.text = "Erreur de connexion réseau."
		return

	var text := body.get_string_from_utf8()

	if response_code == 200 or response_code == 201:
		status_label.text = "Compte créé"
		get_tree().change_scene_to_file(LOGIN_SCENE_PATH)

	elif response_code == 400 or response_code == 409:
		status_label.text = "Ce nom d’utilisateur est déjà utilisé."

	elif response_code >= 500:
		status_label.text = "Erreur serveur, réessaie plus tard."

	else:
		status_label.text = "Erreur inconnue (%d)" % response_code
