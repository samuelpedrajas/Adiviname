extends HTTPRequest

var next_request

signal api_request_completed(result, response_code)


func send_request(url, params={}, headers=PoolStringArray([])):
	connect("request_completed", self, "_on_HTTPRequest_request_completed")
	request(url + dict_to_qstring(params), headers, false)


func dict_to_qstring(dict):
	var url_params = ""
	var first = true
	for key in dict.keys():
		if first:
			first = false
			url_params += "?"
		else:
			url_params += "&"
		url_params += key + "=" + dict[key]
	return url_params
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if(response_code == 200):
		var json_response = JSON.parse(body.get_string_from_utf8())

		if json_response.error != OK:
			print("Some error while parsing the JSON")
			return
		next_request = json_response.result["next"]
		emit_signal("api_request_completed", json_response.result["results"], response_code)
