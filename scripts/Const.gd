extends Node

const GameMode = {
    NORMAL = 0,
    GESTURES = 1,
	SINGING = 2
}

const GyroAnswer = {
	MAX_CORRECT = -3.5,
	MIN_CORRECT = -5,
	MAX_INCORRECT = 5,
	MIN_INCORRECT = 3.5,
	YZ_THRESHOLD = 1
}

const API_HOST = "https://adiviname.herokuapp.com"
const API_GAME_ENDPOINT = API_HOST + "/api/v1/game/"
const API_GAME_CLICK_ENDPOINT = API_HOST + "/api/v1/game_click/"

const ICON_PATH = "user://saved_images/"
