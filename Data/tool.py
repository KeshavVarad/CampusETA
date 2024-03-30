import json

with open('raw.json') as json_file:
    data = json.load(json_file)

    stops = []
    for i in data["data"]:


        if('4017244' in i['routes']):

            stop_id = i['stop_id']
            coords = i['location']
            name = i['name']
            
            my_dict = {"stop_id":stop_id, "location":coords, "name":name}
            stops.append(my_dict)

    
    
    with open('throwaway.json', 'w') as f:
        json.dump({"stops":stops}, f)
