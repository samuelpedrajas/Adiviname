extends HTTPRequest

var last_request_timestamp
var total_requests = 0
var request_count = 0
var method = HTTPClient.METHOD_GET

signal api_request_progress(result, response_code)
signal api_request_completed(result, response_code)
signal api_request_failed(message, response_code)


func _ready():
	connect("request_completed", self, "_on_HTTPRequest_request_completed")


func send_request(url, params={}, headers=PoolStringArray([]), method=HTTPClient.METHOD_GET):
	print("Sending request to %s params: %s" % [url, params])
	request_count = 0
	request(url + dict_to_qstring(params), headers, false, method)


func dict_to_qstring(dict):
	var url_params = ""
	var first = true
	for key in dict.keys():
		if first:
			first = false
			url_params += "?"
		else:
			url_params += "&"
		url_params += key + "=" + str(dict[key])
	return url_params
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var api_result = null
	if(response_code == 200):
		var json_response = JSON.parse(body.get_string_from_utf8())

		if json_response.error != OK:
			print("Some error while parsing the JSON")
		elif json_response.result != null:
			if json_response.result.has("timestamp"):
				last_request_timestamp = json_response.result.timestamp

			if json_response.result.has("results"):
				api_result = json_response.result["results"]

			if json_response.result["next"] != null:
				var count = json_response.result["count"]
				if request_count == 0:
					total_requests = ceil(count / api_result.size())
				request_count += 1
				print("Remaining requests: ", request_count)
				emit_signal("api_request_progress", api_result, response_code, json_response.result["next"])
			else:
				emit_signal("api_request_completed", api_result, response_code)
	else:
		print("Status different than 200: ", response_code)
		emit_signal("api_request_failed", "Cannot update", response_code)
