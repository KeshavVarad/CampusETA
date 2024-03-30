import requests
import json

url = "https://transloc-api-1-2.p.rapidapi.com/arrival-estimates.json"

querystring = {"agencies":"176","stops":"4117202","callback":"call"}

headers = {
	"X-RapidAPI-Key": "65629c31edmsh02d5f387dd070adp1f7446jsn27d7cb0cb7cc",
	"X-RapidAPI-Host": "transloc-api-1-2.p.rapidapi.com"
}

response = requests.get(url, headers=headers, params=querystring)

print(response.json())

mydict = response.json()["data"]


with open('raw4.json', 'w') as f:
    json.dump(mydict, f)


