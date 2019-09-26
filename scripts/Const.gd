extends Node

const GameMode = {
    NORMAL = 0,
    GESTURES = 1,
	SINGING = 2
}

const GyroAnswer = {
	MAX_CORRECT = -4.5,
	MIN_CORRECT = -6,
	MAX_INCORRECT = 6,
	MIN_INCORRECT = 4.5,
	YZ_THRESHOLD = 0.4
}

const API_URL = "http://192.168.2.251:8000/api/v1/game/"
