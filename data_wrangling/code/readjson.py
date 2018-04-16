import json
json_data = open('data/data-text.json', 'r').read()
data = json.loads(json_data)
for item in data:
   print(item)
