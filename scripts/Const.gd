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
	MIN_INCORRECT = 3.5
}

const API_URL = "http://192.168.2.251:8000/api/v1/game/"
