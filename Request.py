from flask import Flask, jsonify
import sqlite3
import requests
import math


app = Flask(__name__)


def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth's radius in km

    # Convert degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c  # Distance in km


def get_coordinates(address):

    url = "https://nominatim.openstreetmap.org/search"
    params = {
        "q": address,
        "format": "json"
    }

    response = requests.get(url, params=params)

    if response.status_code == 200 and response.json():
        data = response.json()[0]  # Get first result
        return {"latitude": data["lat"], "longitude": data["lon"]}
    else:
        return {"error": "Address not found"}


@app.route('/get-pet', methods=['GET'])
def get_pet(address, radius):

    your_coords = get_coordinates(address)

    #TODO: it needs to be in a certain location radius :(
    # Establish connection to DB
    conn = sqlite3.connect('my_database.db') #TODO: REPLACE WITH NAME
    cursor = conn.cursor()

    found = False
    while (found != True):
        #picks a random row
        cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;")
        row = cursor.fetchone()  # Get a single row (fetchone instead of fetchall)

        shelter_coords = get_coordinates(row[2])  #change number here

        distance = haversine(your_coords[0], your_coords[1], shelter_coords[0], shelter_coords[1])  # probably need to change numbers here to to access individual lat and long
        if (distance <= radius):
            found = True

    # Close connection to DB
    conn.close()

    # Check if a row was found and reformmat
    if row:
        output = {"id": row[0], "name": row[1], "age": row[2]} #TODO: MAKE NORMAL PROPERTIES
        return jsonify(output)
    else:
        return jsonify({"error": "No data found"}), 404


#@app.route('/pick-pet', methods=['GET'])
#def pick_pet():

    # Establish connection to DB
    #conn = sqlite3.connect('my_database.db') #TODO: REPLACE WITH NAME
    #cursor = conn.cursor()

    #TODO: make this change the table somehow to connect pet and adopter
    #row = cursor.execute("SELECT * FROM users ORDER BY RANDOM() LIMIT 1;")

    #TODO: check if successful somehow


    # Close connection to DB
    #conn.close()

    # TODO: make it return if successful or not
    #if row:
        #output = {"id": row[0], "name": row[1], "age": row[2]} #TODO: MAKE NORMAL PROPERTIES
        #return jsonify(output)
    #else:
        #return jsonify({"error": "No data found"}), 404


if __name__ == '__main__':
    app.run(debug=True)